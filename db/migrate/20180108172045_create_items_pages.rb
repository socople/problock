class CreateItemsPages < ActiveRecord::Migration[5.0]
  def change
    create_table :items_pages, id: false do |t|
      t.references :item
      t.references :page
    end
  end
end
