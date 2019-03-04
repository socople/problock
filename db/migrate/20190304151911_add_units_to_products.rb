class AddUnitsToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :units, :string, null: false, default: ''
  end
end
