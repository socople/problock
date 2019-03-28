class AddCoordsToQuotation < ActiveRecord::Migration[5.0]
  def change
    add_column :quotations, :latitude, :decimal, precision: 12, scale: 6, null: false, default: 0.0
    add_column :quotations, :longitude, :decimal, precision: 12, scale: 6, null: false, default: 0.0
  end
end
