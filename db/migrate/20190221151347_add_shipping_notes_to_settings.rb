class AddShippingNotesToSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :settings, :shipping_notes, :text
  end
end
