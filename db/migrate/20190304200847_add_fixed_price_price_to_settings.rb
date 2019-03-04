class AddFixedPricePriceToSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :settings, :fixed_price_price, :decimal, precision: 9, scale: 3, null: false, default: 0.0
  end
end
