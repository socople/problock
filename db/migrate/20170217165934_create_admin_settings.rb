class CreateAdminSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :admin_settings do |t|
      t.references :admin, foreign_key: true
      t.text :table_columns

      t.timestamps
    end
  end
end
