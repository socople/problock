#
module Latte
  #
  class ContactsController < LatteController
    include Latte::Crud
    include Latte::Multiple
    include Latte::CsvExportable
    #

    def model
      Contact
    end

    def exportable_fields
      %i[name phone email message created_at]
    end
  end
end
