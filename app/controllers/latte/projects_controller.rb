#
module Latte
  #
  class ProjectsController < LatteController
    include Latte::Crud
    include Latte::Multiple
    include Latte::CsvExportable
    #

    def model
      Project
    end

    def permits
      %i[featured priority name description]
    end

    def exportable_fields
      %i[featured priority name description]
    end
  end
end
