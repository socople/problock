#
module Latte
  #
  module Crud
    extend ActiveSupport::Concern

    included do
      respond_to :html
      before_action :set_item, only: %i[show edit update destroy]
      before_action :authorize_update, only: %i[edit update]

      helper_method :model
    end

    def authorize_update
      authorize @item
    end

    def index
      authorize model

      respond_to do |format|
        format.json { super }
        format.csv  { super }
        format.html { respond_to_html }
      end
    end

    def respond_to_html
      add_breadcrumb t('home'), latte_root_url
      add_breadcrumb humanized_model_name(:many), index_url
      render template: 'concerns/latte/index'
    end

    def new
      @item = model.new

      init_form
      breadcrumbs_for(:new)
      render template: 'concerns/latte/form'
    end

    def create
      @item = model.new item_params
      return redirect_to(edit_url, flash: { saved: true }) if @item.save

      init_form
      breadcrumbs_for(:new)
      render template: 'concerns/latte/form'
    end

    def edit
      init_form
      breadcrumbs_for(:edit)

      render template: 'concerns/latte/form'
    end

    def update
      respond_to do |format|
        format.json { super }
        format.html do
          return redirect_to(edit_url, flash: { saved: true }) if
            @item.update_attributes(item_params)

          breadcrumbs_for(:edit)
          init_form
          render template: 'concerns/latte/form'
        end
      end
    end

    def destroy
      @item.destroy
      redirect_to index_url, flash: { destroyed: true }
    end

    def init_form; end

    private

    def permitted
      perm = permits
      perm.push(:tagging)           if model.respond_to?(:taggable?)
      perm.push(main_image_permits) if model.respond_to?(:main_image?)
      perm.push(cover_permits)      if model.respond_to?(:cover?)

      perm
    end

    def item_params
      params.require(:item).permit(permitted)
    end

    def main_image_permits
      { main_image_attributes: %i[id image _destroy] }
    end

    def cover_permits
      { cover_attributes: %i[id image _destroy] }
    end

    def set_item
      @item = if model.respond_to?(:friendly)
                model.friendly.find params[:id]
              else
                model.find params[:id]
              end
    end

    def edit_url
      url_for(action: :edit, id: @item.id)
    end

    def index_url
      url_for(controller: model.to_s.underscore.pluralize, action: :index)
    end

    def humanized_model_name(count = 1)
      t(model.to_s.underscore, scope: 'activerecord.models', count: count)
    end

    def breadcrumbs_for(action)
      add_breadcrumb t('home'), latte_root_url
      add_breadcrumb humanized_model_name(count: :many), index_url
      add_breadcrumb t(action.to_s), nil
    end
  end
end
