class AddLocaleToFriendlyIdSlugs < ActiveRecord::Migration[5.0]
  def change
    add_column :friendly_id_slugs, :locale, :string, null: false, default: ''
  end
end
