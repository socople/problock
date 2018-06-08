#
module Latte
  #
  class TagsController < LatteController
    def index
      @tags = Tag.order :name
      render json: @tags.map(&:name)
    end
  end
end
