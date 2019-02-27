#
module Latte
  #
  class SettingsController < LatteController
    include Latte::Crud

    def model
      Setting
    end

    def edit_url
      edit_latte_settings_url
    end

    def breadcrumbs_for(action)
      add_breadcrumb t('home'), latte_root_url
      add_breadcrumb t(action.to_s), nil
    end

    def permits
      %i[contact_page_id smtp_host smtp_port smtp_domain smtp_username
         smtp_password smtp_sender_name inbox_name inbox_email
         google_analytics_id app_title app_description gimmick delete_gimmick
         favicon delete_favicon km_price km_extra_price shipping_notes]
    end

    def init_form
      @pages = Page.order :name
    end

    def set_item
      @item = Setting.first
    end
  end
end
