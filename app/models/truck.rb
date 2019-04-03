#
class Truck < ApplicationRecord
  #

  belongs_to :quotation
  has_many :truck_quotation_products, dependent: :destroy
  accepts_nested_attributes_for :truck_quotation_products, allow_destroy: true

  def used_percent
    truck_quotation_products
      .map(&:percent_in_truck)
      .sum
  end

  scope :order_by_products, lambda {
    includes(:truck_quotation_products)
      .order('truck_quotation_products.quotation_product_id asc')
  }

  after_validation :set_expected_date!
  #
  def set_expected_date!
    self.expected_date = nil if expected_asap?
  end

  def expected_date_s
    return 'Tan pronto como sea posible' if expected_asap?
    I18n.l expected_date, format: :localized
  end

  def sendgrid_data
    {
      number: quotation.trucks.index(self) + 1,
      expected_date: expected_date_s,
      truck_quotation_products: truck_quotation_products.map(&:sendgrid_data)
    }
  end

  def unused_percent
    100.0 - used_percent
  end

  def unused_percent?
    unused_percent.positive?
  end

  def other_trucks
    quotation.trucks.where.not(id: id)
  end

  def can_be_divided_in_others?
    return false if truck_quotation_products.count > 1

    other_trucks.sum(&:unused_percent) >= used_percent
  end

  def can_be_divided_equality?
    return false unless can_be_divided_in_others?

    available    = other_trucks.select(&:unused_percent?)
    test_percent = (used_percent / available.count).ceil

    available.all? { |o| o.used_percent + test_percent <= 100 }
  end

  def less_used?
    return false if quotation.trucks.count <= 1

    other_trucks.all? { |o| o.unused_percent <= unused_percent }
  end

  def redistribute!
    return redistribute_equality! if can_be_divided_equality?
    redistribute_adjusting!
  end

  def redistribute_equality_quantities
    tquotaion_product = truck_quotation_products.first
    available         = other_trucks.select(&:unused_percent?)
    quantity          = tquotaion_product.quantity / available.count
    quantities        = Array.new(available.count, quantity.floor)
    quantities[-1]    = quantity + tquotaion_product.quantity % available.count

    quantities
  end

  def redistribute_equality!
    tqproduct = truck_quotation_products.first
    available = other_trucks.select(&:unused_percent?)

    redistribute_equality_quantities.each_with_index do |o, i|
      available[i].truck_quotation_products.create(
        quotation_product_id: tqproduct.quotation_product_id,
        quantity: o
      )
    end

    destroy
    quotation.reload.cleanup!
  end

  def fill_with_truck_quotation_product(tqp)
    quantity = tqp.percent_to_quantity(unused_percent).floor
    quantity = tqp.quantity if quantity > tqp.quantity

    truck_quotation_products.create(
      quotation_product_id: tqp.quotation_product_id,
      quantity: quantity
    )

    tqp.update_column :quantity, tqp.quantity - quantity
  end

  def redistribute_adjusting!
    available = other_trucks.select(&:unused_percent?)
    available.each do |x|
      tqproduct = truck_quotation_products.first
      x.fill_with_truck_quotation_product(tqproduct)
    end

    destroy
    quotation.reload.cleanup!
  end
end
