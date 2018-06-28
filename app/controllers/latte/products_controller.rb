#
module Latte
  #
  class ProductsController < LatteController
    include Latte::Crud
    include Latte::Multiple
    include Latte::CsvExportable
    #

    def model
      Product
    end

    def permits
      %i[category_id priority name description]
    end

    def exportable_fields
      %i[category_id priority name description]
    end

    def init_form
      @categories = Category.main
    end
  end
end
