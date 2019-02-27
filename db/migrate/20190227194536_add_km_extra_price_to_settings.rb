class AddKmExtraPriceToSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :settings, :km_extra_price, :decimal, precision: 9, scale: 3, null: false, default: 1.0
  end
end
