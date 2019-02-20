class AddStatusToQuotation < ActiveRecord::Migration[5.0]
  def change
    add_column :quotations, :status, :integer, null: false, default: 0
  end
end
