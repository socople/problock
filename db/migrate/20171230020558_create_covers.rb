class CreateCovers < ActiveRecord::Migration[5.0]
  def change
    create_table :covers do |t|
      t.references :coverable, polymorphic: true
      t.attachment :image
      t.integer :image_width, null: false, default: 0
      t.integer :image_height, null: false, default: 0

      t.timestamps
    end
  end
end
