#
module Latte
  #
  class ImagesController < LatteController
    #
    def list
      model   = params[:imageable_type].constantize
      @images = model.find(params[:imageable_id]).images.order(:priority)
      render json: @images
    end

    def sort
      sort_params.each { |k, v| Image.find(k).update_column :priority, v }
      head :no_content
    end

    def create
      @image = Image.new item_params
      return render json: @image if @image.save
      render json: @image.errors, status: :unprocessable_entity
    end

    def update
      @image = Image.find(params[:id])

      return render json: @image if @image.update_attributes(update_item_params)
      render json: @image.errors, status: :unprocessable_entity
    end

    def destroy
      Image.find(params[:id]).destroy
      head :no_content
    end

    private

    def sort_params
      params.require(:priorities)
    end

    def item_params
      params
        .require(:image)
        .permit(:imageable_type, :imageable_id, :image, :description)
    end

    def update_item_params
      params
        .require(:image)
        .permit(:image, :description)
    end
  end
end
