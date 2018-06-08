#
module Latte
  #
  class ActivityLogsController < LatteController
    include Latte::Crud
    include Latte::Multiple
    include Latte::CsvExportable
    include Latte::VersionUtilities

    def show
      @version = model.find params[:id]
      add_breadcrumb t('activerecord.models.activity_log', count: :many),
                     url_for(action: :index)
    end

    def model
      ActivityLog
    end

    def exportable_fields
      %i[item_type item_id whodunnit created_at]
    end
  end
end
