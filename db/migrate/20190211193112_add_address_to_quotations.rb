class AddAddressToQuotations < ActiveRecord::Migration[5.0]
  def change
    add_column :quotations, :address, :text
  end
end
