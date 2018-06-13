#
class ProductsController < ApplicationController
  def index
    add_breadcrumb 'Inicio', root_url
    add_breadcrumb 'Productos', products_url
  end
end
