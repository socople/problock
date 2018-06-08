#
module Latte
  #
  class RecyclerDocksController < LatteController
    include Latte::Crud
    include Latte::Multiple
    include Latte::CsvExportable
    include Latte::VersionUtilities

    def show
      @version = RecyclerDock.find params[:id]
      add_breadcrumb t('activerecord.models.recycler_dock', count: :many),
                     url_for(action: :index)
    end

    def model
      RecyclerDock
    end

    def exportable_fields
      %i[item_type item_id whodunnit created_at]
    end

    def restore
      @version = RecyclerDock.find params[:id]
      if @version.reify
        @item = @version.reify
        @item.save(validate: false)
        @version.destroy
      end

      redirect_to(url_for(action: :index), flash: { restored: edit_item_url })
    end

    def edit_item_url
      url_for(
        controller: @version.item_type.underscore.pluralize,
        action: :edit,
        id: @item.id
      )
    end
  end
end
