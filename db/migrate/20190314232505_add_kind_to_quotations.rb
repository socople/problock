class AddKindToQuotations < ActiveRecord::Migration[5.0]
  def change
    add_column :quotations, :kind, :integer, null: true, default: nil
  end
end
