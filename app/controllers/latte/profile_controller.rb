#
module Latte
  #
  class ProfileController < LatteController
    include Latte::Crud

    def model
      Admin
    end

    def edit
      breadcrumbs_for(:edit)
      @user = model.find current_admin.id
      redirect_to admin_root_url if @user != current_admin
    end

    def update
      @user = model.find current_admin.id
      if @user.update_attributes item_params
        sign_in @user, bypass: true
        redirect_to(edit_url, flash: { saved: true })
      else
        breadcrumbs_for(:edit)
        render template: 'latte/profile/edit'
      end
    end

    def breadcrumbs_for(action)
      add_breadcrumb t('home'), latte_root_url
      add_breadcrumb t(action.to_s), nil
    end

    def item_params
      params.require(:admin).permit(
        :name,
        :lastname,
        :password,
        :password_confirmation
      )
    end
  end
end
