#
class QuotationsController < ApplicationController
  def new
    @quotation = Quotation.new

    init_form
    add_breadcrumb 'Inicio', root_url
    add_breadcrumb 'Cotizador', new_quotation_url
  end

  def init_form
    @categories = Category.with_products.order :name
  end

  def show_map?
    false
  end

  def quotation_map?
    true
  end
end
