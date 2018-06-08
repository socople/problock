class AddTrigramExtension < ActiveRecord::Migration[5.0]
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS pg_trgm;'
  end

  def down
    execute 'DROP EXTENSION IF EXISTS pg_trgm CASCADE;'
  end
end
