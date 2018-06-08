#
class PagesController < ApplicationController
  def show
    @page = Page.find params[:id]
    set_meta_tags @page.metatags
  end
end
