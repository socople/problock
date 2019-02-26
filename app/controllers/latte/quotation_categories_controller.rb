#
module Latte
  #
  class QuotationCategoriesController < LatteController
    include Latte::Crud
    include Latte::Multiple
    include Latte::CsvExportable
    #

    def model
      QuotationCategory
    end

    def permits
      %i[priority name]
    end

    def exportable_fields
      %i[priority name]
    end
  end
end
