#
module Latte
  #
  class AttachmentsController < LatteController
    #
    def list
      model = params[:attachable_type].constantize
      @attachments = model
                     .find(params[:attachable_id])
                     .attachments
                     .order(:priority)

      render json: @attachments
    end

    def sort
      sort_params.each { |k, v| Attachment.find(k).update_column :priority, v }
      head :no_content
    end

    def create
      @attachment = Attachment.new item_params
      return render json: @attachment if @attachment.save
      render json: @attachment.errors, status: :unprocessable_entity
    end

    def update
      @attachment = Attachment.find(params[:id])

      return render json: @attachment if @attachment
                                         .update_attributes(update_item_params)

      render json: @attachment.errors, status: :unprocessable_entity
    end

    def destroy
      Attachment.find(params[:id]).destroy
      head :no_content
    end

    private

    def sort_params
      params.require(:priorities)
    end

    def item_params
      params
        .require(:attachment)
        .permit(:attachable_type, :attachable_id, :attachment, :name,
                :description)
    end

    def update_item_params
      params
        .require(:attachment)
        .permit(:attachment, :name, :description)
    end
  end
end
