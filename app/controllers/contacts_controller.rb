#
class ContactsController < ApplicationController
  def new
    @contact = Contact.new
    build_breadcrumb
  end

  def build_breadcrumb
    add_breadcrumb 'Inicio', root_url
    add_breadcrumb 'Contáctenos', new_contact_url
  end
end
