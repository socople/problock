#
class TruckQuotationProduct < ApplicationRecord
  belongs_to :truck
  belongs_to :quotation_product

  def percent_in_truck
    100.0 / quotation_product.product.units_by_truck * quantity.to_f
  end
end
