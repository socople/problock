class CreateImages < ActiveRecord::Migration[5.0]
  def up
    create_table :images do |t|
      t.integer :priority, null: false, default: 0
      t.references :imageable, polymorphic: true
      t.attachment :image
      t.integer :image_width, null: false, default: 0
      t.integer :image_height, null: false, default: 0

      t.timestamps
    end

    Image.create_translation_table! description: :text
  end

  def down
    Image.drop_translation_table!
    drop_table :images
  end
end
