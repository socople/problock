#
module Latte
  #
  class AdminsController < LatteController
    include Latte::Crud
    include Latte::Multiple
    include Latte::CsvExportable
    #

    def model
      Admin
    end

    def permits
      %i[name email password password_confirmation]
    end

    def exportable_fields
      %i[name email]
    end

    def init_form; end

    def update
      @item.attributes = item_params
      m = @item.password.blank? ? :update_without_password : :update_attributes

      return redirect_to(edit_url, flash: { saved: true }) if
        @item.send(m, item_params)

      breadcrumbs_for(:edit)
      init_form
      render template: 'concerns/latte/form'
    end
  end
end
