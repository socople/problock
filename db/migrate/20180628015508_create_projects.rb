class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.integer :priority, null: false, default: 0
      t.string :name, null: false, default: ''
      t.text :description

      t.timestamps
    end
  end
end
