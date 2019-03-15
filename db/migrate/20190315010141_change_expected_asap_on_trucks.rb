class ChangeExpectedAsapOnTrucks < ActiveRecord::Migration[5.0]
  def up
    change_column :trucks, :expected_asap, :boolean, null: false, default: true
  end

  def down
    change_column :trucks, :expected_asap, :boolean, null: false, default: false
  end
end
