class AddReferencePointToQuotations < ActiveRecord::Migration[5.0]
  def change
    add_column :quotations, :reference_point, :text
  end
end
