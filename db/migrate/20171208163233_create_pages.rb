#
class CreatePages < ActiveRecord::Migration[5.0]
  def up
    create_table :pages do |t|
      t.boolean :enabled, null: false, default: false
      t.integer :priority, null: false, default: 0
      t.boolean :in_header, null: false, default: false
      t.boolean :in_footer, null: false, default: false

      t.timestamps
    end

    Page.create_translation_table! name: :string,
                                   description: :text,
                                   content: :text,
                                   slug: {
                                     type: :string,
                                     index: true,
                                     unique: true
                                   }
  end

  def down
    Page.drop_translation_table!
    drop_table :pages
  end
end
