class CreateMainImages < ActiveRecord::Migration[5.0]
  def change
    create_table :main_images do |t|
      t.references :main_imageable, polymorphic: true
      t.attachment :image
      t.integer :image_width, null: false, default: 0
      t.integer :image_height, null: false, default: 0

      t.timestamps
    end
  end
end
