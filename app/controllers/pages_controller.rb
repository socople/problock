#
class PagesController < ApplicationController
  def about
    add_breadcrumb 'Inicio', root_url
    add_breadcrumb 'Quiénes somos', nil
  end
end
