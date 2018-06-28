class CreateCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
      t.references :category, foreign_key: true
      t.boolean :featured, null: false, default: false
      t.integer :priority, null: false, default: 0
      t.string :name, null: false, default: ''
      t.text :description
      t.string :slug

      t.timestamps
    end
    add_index :categories, :slug, unique: true
  end
end
