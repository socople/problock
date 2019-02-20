#
class QuotationsController < ApplicationController
  def new
    @quotation = Quotation.new

    init_form
    add_breadcrumb 'Inicio', root_url
    add_breadcrumb 'Cotizador', new_quotation_url
  end

  def create
    @quotation = Quotation.new item_params
    return redirect_to edit_quotation_url(@quotation) if @quotation.save

    init_form
    render action: :new
  end

  def edit
    @quotation = Quotation.find params[:id]
  end

  def init_form
    @categories = Category.with_products.order :name
  end

  def item_params
    params.require(:quotation).permit(
      :customer_name, :email, :phone, :cellphone, :address, :distance,
      quotation_products_attributes: %i[id product_id quantity _destroy]
    )
  end

  def show_map?
    false
  end

  def quotation_map?
    true
  end
end