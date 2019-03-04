#
class Truck < ApplicationRecord
  #

  belongs_to :quotation
  has_many :truck_quotation_products, dependent: :destroy
  accepts_nested_attributes_for :truck_quotation_products, allow_destroy: true

  def accommodated_products_percent
    truck_quotation_products
      .map(&:quotation_product)
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
end
