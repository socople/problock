#
class QuotationsController < ApplicationController
  def new
    @quotation = if params.key?(:o)
                   Quotation.find params[:o]
                 else
                   Quotation.new
                 end

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

  def confirm
    @quotation = Quotation.find params[:id]
    @quotation.update_attributes(confirm_params)

    redirect_to confirmed_quotation_url(@quotation)
  end

  def edit
    @quotation = Quotation.find params[:id]

    return redirect_to confirmed_quotation_url(@quotation) unless
                                                           @quotation.kind.nil?
    init_form
  end

  def show
    @quotation = Quotation.find params[:id]
    redirect_to confirmed_quotation_url(@quotation) unless @quotation.kind.nil?
  end

  def confirmed
    @quotation = Quotation.find params[:id]
  end

  def update
    @quotation = Quotation.find params[:id]

    if @quotation.update_attributes(item_params)
      @quotation.cleanup!
      return redirect_to update_redirect_to_url
    end

    init_form
    render update_render_action
  end

  def update_redirect_to_url
    return quotation_url(@quotation) if @quotation.step2?
    edit_quotation_url(@quotation)
  end

  def update_render_action
    return { action: :edit } if @quotation.step2?
    { action: :new }
  end

  def init_form
    @quotation_categories = QuotationCategory.priority
  end

  def item_params
    params.require(:quotation).permit(
      :distance_extra, :customer_name, :phone, :cellphone, :address, :distance,
      :email, :status, :reference_point,
      quotation_products_attributes: %i[id product_id quantity _destroy],
      trucks_attributes: [
        :id, :quotation_id, :expected_asap, :expected_date, :_destroy,
        truck_quotation_products_attributes: %i[id truck_id quotation_product_id
                                                quantity _destroy]
      ]
    )
  end

  def confirm_params
    params.require(:quotation).permit(:kind)
  end

  def show_map?
    false
  end

  def quotation_map?
    true
  end
end
