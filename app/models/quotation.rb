#
class Quotation < ApplicationRecord
  #
  enum status: %i[step1 step2]
  #
  attr_accessor :expected_asap
  #
  has_many :trucks, -> { order_by_products }, dependent: :destroy
  accepts_nested_attributes_for :trucks

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

  after_create :complete_info
  #
  def complete_info
    accommodate_products
    set_shipping_price!
  end

  def set_shipping_price!
    update_column :shipping_price, calculated_shipping_price
  end

  def calculated_shipping_price
    if (distance / 1000.0) + distance_extra <= Setting.fixed_price_distance
      return fixed_shipping_price
    end
    total_distance_price
  end

  def fixed_shipping_price
    Setting.fixed_price_distance * trucks.count
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
    return 0 if distance_extra.zero?
    distance_extra * Setting.km_extra_price * trucks.count * 2
  end

  def accommodate_products
    qp = qp2accommodate
    while qp.any?
      distribute_products
      qp = qp2accommodate
    end
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
    trucks.each do |o|
      o.destroy if o.truck_quotation_products.empty?
    end
  end

  def refresh_quantities!
    quotation_products.each do |o|
      o.update_column :quantity, o.truck_quotation_products.sum(:quantity)
    end
  end
end
