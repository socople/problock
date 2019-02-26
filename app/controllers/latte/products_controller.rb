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
      %i[category_id priority price units_by_truck name description
         quotation_priority quotation_category_id]
    end

    def exportable_fields
      %i[category_id priority price units_by_truck name description
         quotation_priority quotation_category_id]
    end

    def init_form
      @categories = Category.main
      @quotation_categories = QuotationCategory.order :name
    end
  end
end
