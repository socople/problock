class CreateTrucks < ActiveRecord::Migration[5.0]
  def change
    create_table :trucks do |t|
      t.references :quotation, foreign_key: true
      t.date :expected_date, null: true, default: nil

      t.timestamps
    end
  end
end
