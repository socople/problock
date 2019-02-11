class AddFieldsToQuotation < ActiveRecord::Migration[5.0]
  def change
    add_column :quotations, :customer_name, :string, null: false, default: ''
    add_column :quotations, :email, :string, null: false, default: ''
    add_column :quotations, :phone, :string, null: false, default: ''
    add_column :quotations, :cellphone, :string, null: false, default: ''
    add_column :quotations, :expected_date, :date, null: true, default: nil
    add_column :quotations, :distance, :integer, null: false, default: 0
  end
end
