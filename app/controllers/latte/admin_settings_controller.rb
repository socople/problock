#
module Latte
  #
  class AdminSettingsController < LatteController
    before_action :fetch_admin_setting

    def table_columns
      @admin_setting.update_table_columns(item_params[:table_columns])
    end

    # private

    def item_params
      params.require(:admin_setting).tap do |whitelisted|
        whitelisted[:table_columns] = params[:admin_setting][:table_columns]
      end
    end

    def fetch_admin_setting
      @admin_setting = AdminSetting
                       .where(admin_id: current_admin.id)
                       .first_or_create
    end
  end
end
