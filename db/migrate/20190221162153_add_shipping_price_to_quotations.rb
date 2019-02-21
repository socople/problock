class AddShippingPriceToQuotations < ActiveRecord::Migration[5.0]
  def change
    add_column :quotations, :shipping_price, :decimal, precision: 9, scale: 3, null: false, default: 0
  end
end
