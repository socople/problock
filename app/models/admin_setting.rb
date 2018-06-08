#
class AdminSetting < ApplicationRecord
  belongs_to :admin

  serialize :table_columns, Hash

  def update_table_columns(data)
    current_data = table_columns || {}
    update_column :table_columns, current_data.merge(data)
  end
end
