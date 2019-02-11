class AddPriceToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :price, :decimal, precision: 10, scale: 4, null: false, default: 0
  end
end
