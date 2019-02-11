class AddUnitsByTruckToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :units_by_truck, :integer, null: false, default: 0
  end
end
