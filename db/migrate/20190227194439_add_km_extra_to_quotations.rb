class AddKmExtraToQuotations < ActiveRecord::Migration[5.0]
  def change
    add_column :quotations, :distance_extra, :integer, null: true, default: nil
  end
end
