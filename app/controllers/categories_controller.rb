#
class CategoriesController < ApplicationController
  def show
    @categories = Category.main.priority
    @category   = Category.find params[:id]
    @main       = @category.category.nil? ? @category : @category.category

    build_breadcrumb
  end

  def build_breadcrumb
    add_breadcrumb 'Inicio', root_url
    add_breadcrumb 'Productos', category_url(main_category)
    add_breadcrumb @main.name, category_url(@main)
    add_breadcrumb @category.name, category_url(@category) if @category != @main
  end
end
