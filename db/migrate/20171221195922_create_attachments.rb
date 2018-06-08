class CreateAttachments < ActiveRecord::Migration[5.0]
  def up
    create_table :attachments do |t|
      t.integer :priority, null: false, default: 0
      t.references :attachable, polymorphic: true
      t.attachment :attachment
      t.integer :downloads, null: false, default: 0

      t.timestamps
    end

    Attachment.create_translation_table! name: :string, description: :text
  end

  def down
    Attachment.drop_translation_table!
    drop_table :attachments
  end
end
