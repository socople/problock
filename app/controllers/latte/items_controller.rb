#
module Latte
  #
  class ItemsController < LatteController
    include Latte::Crud
    include Latte::Multiple
    include Latte::CsvExportable
    #

    def model
      Item
    end

    def permits
      %i[name]
    end

    def exportable_fields
      %i[name]
    end
  end
end
