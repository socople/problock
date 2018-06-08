#
module Latte
  #
  class PagesController < LatteController
    include Latte::Crud
    include Latte::Multiple
    include Latte::CsvExportable
    #

    def model
      Page
    end

    def permits
      [:enabled, :priority, :in_header, :in_footer, :name, :description,
       :content, :slug, item_ids: []]
    end

    def exportable_fields
      %i[enabled priority in_header in_footer name description content]
    end
  end
end
