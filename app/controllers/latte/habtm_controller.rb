#
module Latte
  #
  class HabtmController < LatteController
    #
    def available
      response = available_items.map do |o|
        { id: o.id, name: o.send(model.acts_as_label) }
      end
      render json: response
    end

    def enabled
      response = enabled_items.map do |o|
        { id: o.id, name: o.send(model.acts_as_label) }
      end
      render json: response
    end

    def available_items
      policy_scope(model)
        .where.not(id: enabled_items.map(&:id))
        .order(model.acts_as_label)
    end

    def enabled_items
      return [] if item.nil?
      item.send(collection)
    end

    def model
      params[:model].camelize.constantize
    end

    def collection
      params[:model].pluralize
    end

    def item
      return if params[:item_type].blank? || params[:item_id].blank?
      params[:item_type].camelize.constantize.find params[:item_id]
    end
  end
end
