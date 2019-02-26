class AddQuotationPriorityToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :quotation_priority, :integer, null: false, default: 0
  end
end
