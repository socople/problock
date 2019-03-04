#
class TruckQuotationProduct < ApplicationRecord
  belongs_to :truck
  belongs_to :quotation_product

  def percent_in_truck
    100.0 / quotation_product.product.units_by_truck * quantity.to_f
  end

  def name
    u = quotation_product.product.units
    u = u.pluralize(I18n.locale) if quantity > 1
    q = [quantity, u].join(' ')
    [q, quotation_product.name].join(' de ')
  end

  def name_html
    u = quotation_product.product.units
    u = u.pluralize(I18n.locale) if quantity > 1
    q = ["<span>#{quantity}</span>", u].join(' ')
    [q, quotation_product.name].join(' de ')
  end
end
