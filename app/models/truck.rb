#
class Truck < ApplicationRecord
  belongs_to :quotation
  has_many :truck_quotation_products, dependent: :destroy

  def accommodated_products_percent
    truck_quotation_products
      .map(&:quotation_product)
      .map(&:percent_in_truck)
      .sum
  end
end
