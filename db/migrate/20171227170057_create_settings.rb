class CreateSettings < ActiveRecord::Migration[5.0]
  def up
    create_table :settings do |t|
      t.string :name, null: false, default: ''
      t.integer :contact_page_id, null: true, default: nil
      t.string :smtp_host, null: false, default: ''
      t.integer :smtp_port, null: true, default: nil
      t.string :smtp_domain, null: false, default: ''
      t.string :smtp_username, null: false, default: ''
      t.string :smtp_password, null: false, default: ''
      t.string :smtp_sender_name, null: false, default: ''
      t.string :inbox_name, null: false, default: ''
      t.string :inbox_email, null: false, default: ''
      t.string :google_analytics_id, null: false, default: ''
      t.attachment :gimmick
      t.integer :gimmick_width, null: false, default: 0
      t.integer :gimmick_height, null: false, default: 0
      t.attachment :favicon

      t.timestamps
    end

    Setting.create_translation_table! app_title: :string, app_description: :text
  end

  def down
    Setting.drop_translation_table!
    drop_table :settings
  end
end
