#
class HomeController < ApplicationController
  def index
    @pages = Page.all
    @featured_categories = Category.featured.priority
    @projects = Project.featured.priority
  end
end
