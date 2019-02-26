class CreateQuotationCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :quotation_categories do |t|
      t.integer :priority, null: false, default: 0
      t.string :name, null: false, default: ''

      t.timestamps
    end
  end
end
