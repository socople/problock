#
class QuotationProduct < ApplicationRecord
  #
  belongs_to :product
  belongs_to :quotation
  has_many :truck_quotation_products, dependent: :destroy

  validates :product_id, presence: true

  validates :quantity, presence: true,
                       numericality: {
                         only_integer: true,
                         greater_than: 0
                       }

  before_create :fill_product_fields!
  #
  def fill_product_fields!
    self.name  = product.name
    self.price = product.price
  end

  def subtotal
    quantity.to_f * price
  end

  def percent_in_truck
    100.0 / product.units_by_truck * quantity.to_f
  end

  def truck_to_fit
    return nil if quotation.trucks.empty?
    quotation.trucks.each do |truck|
      return truck if truck.accommodated_products_percent +
                      percent_in_truck <= 100
    end
    nil
  end

  def pending
    quantity - truck_quotation_products.sum(&:quantity)
  end

  def pending_percent
    100.0 / product.units_by_truck * pending.to_f
  end

  def overload_truck?
    pending_percent > 100
  end

  def fittable_quantity
    return product.units_by_truck if overload_truck?
    pending
  end
end
