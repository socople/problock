# rubocop:disable ClassLength
#
class Quotation < ApplicationRecord
  #
  enum status: %i[step1 step2]
  enum kind:   %i[quotation request]
  #
  has_many :trucks, -> { order_by_products }, dependent: :destroy
  accepts_nested_attributes_for :trucks,
                                allow_destroy: true

  has_many :truck_quotation_products, through: :trucks

  has_many :quotation_products, dependent: :destroy
  accepts_nested_attributes_for :quotation_products,
                                allow_destroy: true

  validates :customer_name, presence: true
  validates :address,       presence: true

  validates :email, presence: true
  validates :email,
            format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i },
            if: proc { |o| o.email.present? }

  validates :distance_extra,
            presence: true,
            numericality: {
              only_integer: true
            }

  validates :phone,
            presence: true,
            unless: proc { |o| o.cellphone.present? }

  validates :cellphone,
            presence: true,
            unless: proc { |o| o.phone.present? }

  after_save :send_mail
  #
  def send_mail
    return if kind.blank?
    # LatteMailer.quotation(self).deliver_now

    [email, Setting.inbox_email].each do |to|
      mail = Sendgrid.new(
        from: "#{Setting.inbox_name} <#{Setting.inbox_email}>",
        to: to,
        template_id: mail_template_id
      )

      mail.setup_dynamic_template_data sendgrid_data
      mail.send
    end
  end

  def mail_template_id
    return 'd-a2e7882e6187469e9d379c423a41d229' if quotation?
    'd-f0e07454c2254dc9b1c24622d28700a2'
  end

  def products_total
    quotation_products.map(&:subtotal).sum
  end

  def total
    products_total + shipping_price
  end

  def qp2accommodate
    quotation_products.reload
    quotation_products.select  { |x| x.pending.positive? }
                      .sort_by { |x| -x.pending }
  end

  after_save :complete_info
  #
  def complete_info
    accommodate_products
    set_shipping_price!
  end

  def set_shipping_price!
    update_column :shipping_price, calculated_shipping_price
  end

  def calculated_shipping_price
    if (distance / 1000.0) + distance_extra.to_f <= Setting.fixed_price_distance
      return fixed_shipping_price
    end
    total_distance_price
  end

  def fixed_shipping_price
    Setting.fixed_price_price * trucks.count
  end

  def total_distance_price
    extra = distance_extra_price
    return distance_price if extra.zero?

    distance_price + extra
  end

  def distance_price
    distance / 1000.0 * Setting.km_price * trucks.count * 2
  end

  def distance_extra_price
    return 0 if distance_extra.to_f.zero?
    distance_extra * Setting.km_extra_price * trucks.count * 2
  end

  def accommodate_products
    return if step2?

    trucks.destroy_all
    qp = qp2accommodate
    while qp.any?
      distribute_products
      qp = qp2accommodate
    end

    redistribute!
  end

  def distribute_products
    qp2accommodate.each do |o|
      t = o.truck_to_fit || trucks.build
      t.truck_quotation_products
       .build quotation_product: o,
              quantity: o.fittable_quantity

      t.save
    end
  end

  def cleanup!
    remove_unused_trucks!
    refresh_quantities!
    set_shipping_price!
  end

  def remove_unused_trucks!
    trucks.reload.each do |o|
      o.destroy unless o.truck_quotation_products.reload.any?
    end
  end

  def refresh_quantities!
    quotation_products.reload.each do |o|
      q = o.truck_quotation_products.sum(:quantity)
      if q.zero?
        o.destroy
      else
        o.update_column :quantity, o.truck_quotation_products.sum(:quantity)
      end
    end
  end

  def distance_extra_s
    return 'La entrega es exactamente en el punto "B"' if distance_extra.zero?
    "#{distance_extra} km"
  end

  def reference_point_s
    return 'N/A' if reference_point.blank?
    reference_point
  end

  def sendgrid_data
    {
      customer_name: customer_name, address: address,
      products_total: number_helper.number_to_currency(products_total),
      shipping_price: number_helper.number_to_currency(shipping_price),
      total: number_helper.number_to_currency(total),
      reference_point: reference_point_s,
      distance_extra: distance_extra_s,
      latitude: latitude, longitude: longitude,
      trucks: trucks.map(&:sendgrid_data)
    }
  end

  def truck_to_redistribute
    truck = trucks.find(&:can_be_divided_equality?)
    truck = trucks.find(&:less_used?) if truck.nil?

    truck
  end

  def redistribute!
    return unless trucks.any?(&:can_be_divided_in_others?)

    truck = truck_to_redistribute
    return if truck.nil?

    truck.redistribute!
  end

  private

  def number_helper
    @helper ||= Class.new do
      include ActionView::Helpers::NumberHelper
    end.new
  end
end
