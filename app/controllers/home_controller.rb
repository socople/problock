#
class HomeController < ApplicationController
  def index
    @pages = Page.all
    @featured_categories = Category.featured.priority
  end
end
