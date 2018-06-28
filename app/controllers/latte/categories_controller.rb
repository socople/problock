#
module Latte
  #
  class CategoriesController < LatteController
    include Latte::Crud
    include Latte::Multiple
    include Latte::CsvExportable
    #

    def model
      Category
    end

    def permits
      %i[featured category_id priority name description slug]
    end

    def exportable_fields
      %i[featured category_id priority name description slug]
    end

    def init_form
      where_not = {}
      where_not[:id] = @item.id unless @item.try(:id).nil?
      @categories = Category
                    .where(category_id: nil)
                    .where.not(where_not)
                    .order(:priority)
    end
  end
end
