#
class ContactsController < ApplicationController
  def new
    @contact = Contact.new
    build_breadcrumb
  end

  def create
    @contact = Contact.new item_params
    return redirect_to new_contact_url, notice: :sent if @contact.save

    build_breadcrumb
    render action: :new
  end

  def item_params
    params.require(:contact).permit(:name, :phone, :email, :message)
  end

  def build_breadcrumb
    add_breadcrumb 'Inicio', root_url
    add_breadcrumb 'Contáctenos', new_contact_url
  end
end
