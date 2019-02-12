class RemoveExpectedDateFromQuotations < ActiveRecord::Migration[5.0]
  def change
    remove_column :quotations, :expected_date, :date, null: true, default: nil
  end
end
