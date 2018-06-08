class CreateTags < ActiveRecord::Migration[5.0]
  def up
    create_table :tags do |t|
      t.string :locale, null: false, default: ''
      t.string :name, null: false, default: ''
      t.string :slug, index: true, unique: true
      t.timestamps
    end
  end

  def down
    drop_table :tags
  end
end
