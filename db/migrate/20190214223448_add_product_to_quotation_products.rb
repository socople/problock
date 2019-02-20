class AddProductToQuotationProducts < ActiveRecord::Migration[5.0]
  def change
    add_reference :quotation_products, :product, foreign_key: true
  end
end
