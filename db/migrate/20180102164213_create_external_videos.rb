class CreateExternalVideos < ActiveRecord::Migration[5.0]
  def up
    create_table :external_videos do |t|
      t.integer :priority, null: false, default: 0
      t.references :external_videoable, polymorphic: true, index: { name: 'external_videoable_idx' }
      t.string :url, null: false, default: ''

      t.timestamps
    end

    ExternalVideo.create_translation_table! name: :string, description: :text
  end

  def down
    ExternalVideo.drop_translation_table!
    drop_table :external_videos
  end
end
