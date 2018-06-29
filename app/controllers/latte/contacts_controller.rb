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

    def show
      @contact = Contact.find(params[:id]).decorate
      add_breadcrumb t('home'), latte_root_url
      add_breadcrumb t('activerecord.models.contact', count: :many),
                     url_for(action: :index)
    end

    def exportable_fields
      %i[name phone email message created_at]
    end
  end
end
