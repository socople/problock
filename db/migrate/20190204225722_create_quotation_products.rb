class CreateQuotationProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :quotation_products do |t|
      t.references :quotation, foreign_key: true
      t.string :name, null: false, default: ''
      t.integer :quantity, null: false, default: 0
      t.decimal :price, precision: 8, scale: 2, null: false, default: 0.0

      t.timestamps
    end
  end
end
