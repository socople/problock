class AddExpectedAsapToTrucks < ActiveRecord::Migration[5.0]
  def change
    add_column :trucks, :expected_asap, :boolean, null: false, default: false
  end
end
