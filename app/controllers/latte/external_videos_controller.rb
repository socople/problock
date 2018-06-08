#
module Latte
  #
  class ExternalVideosController < LatteController
    #
    def list
      model = params[:external_videoable_type].constantize
      @external_videos = model
                         .find(params[:external_videoable_id])
                         .external_videos
                         .order(:priority)

      render json: @external_videos
    end

    def sort
      sort_params.each do |k, v|
        ExternalVideo.find(k).update_column :priority, v
      end
      head :no_content
    end

    def create
      @external_video = ExternalVideo.new item_params
      return render json: @external_video if @external_video.save
      render json: @external_video.errors, status: :unprocessable_entity
    end

    def update
      @external_video = ExternalVideo.find(params[:id])

      return render json: @external_video if @external_video
                                             .update_attributes(
                                               update_item_params
                                             )

      render json: @external_video.errors, status: :unprocessable_entity
    end

    def destroy
      ExternalVideo.find(params[:id]).destroy
      head :no_content
    end

    private

    def sort_params
      params.require(:priorities)
    end

    def item_params
      params
        .require(:external_video)
        .permit(:external_videoable_type, :external_videoable_id,
                :external_video, :name, :description, :url)
    end

    def update_item_params
      params
        .require(:external_video)
        .permit(:external_video, :name, :description, :url)
    end
  end
end
