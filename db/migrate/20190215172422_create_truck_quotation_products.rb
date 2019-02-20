class CreateTruckQuotationProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :truck_quotation_products do |t|
      t.references :truck, foreign_key: true
      t.references :quotation_product, foreign_key: true
      t.integer :quantity, null: false, default: 0

      t.timestamps
    end
  end
end
