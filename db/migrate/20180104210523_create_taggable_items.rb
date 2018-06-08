class CreateTaggableItems < ActiveRecord::Migration[5.0]
  def change
    create_table :taggable_items do |t|
      t.references :taggable, polymorphic: true
      t.references :tag, foreign_key: true

      t.timestamps
    end
  end
end
