# frozen_string_literal: true
module Latte
  module Grid
    #
    module Mtable
      extend ActiveSupport::Concern

      included do
        respond_to :json
      end

      def new
        render json: model.new.as_json(json_options)
      end

      def create
        ids, attributes = items
        jitems = create_or_update(ids, attributes)
        render json: json_items(jitems)
      end

      def json_items(jitems)
        { items: jitems,
          errors: jitems.any? { |i| i[:record_status.to_s] != 'OK' } }
      end

      def create_or_update(ids, attributes)
        result = []
        ids.each_with_index do |id, index|
          item = model.where(id: id).first_or_initialize
          item.attributes = attributes[index]
          next if reject_item?(item)
          item.save_permitted(permits)
          result.push(item.decorate.as_json(json_options))
        end
        result
      end

      def clear?(v)
        return !v       if v.is_a?(TrueClass) || v.is_a?(FalseClass)
        return v.blank? if v.is_a?(Date) || v.is_a?(Time)
        v.to_f.zero?
      end

      def reject_item?(item)
        return false unless item.new_record?

        item.attributes
            .select { |k, _| perms.include?(k.to_sym) }
            .all? { |k, v| model.column_defaults[k] == v || clear?(v) }
      end

      def index
        respond_to do |format|
          format.html { render template: 'concerns/latte/grid/index' }
          format.json { respond_to_json }
        end
      end

      def respond_to_json
        @q = policy_scope(model).reorder(:created_at).ransack(params[:filter])
        @c = @q.result
        render json: json_parsed(@c)
      end

      def json_options
        { only: perms, methods: [:record_status] }
      end

      def json_parsed(c)
        return [model.new.as_json(json_options)] if c.empty?
        c.decorate.as_json(json_options)
      end

      def perms
        @perms ||= begin
          perm = permits
          perm.push(:id) unless permits.include?(:id)
          perm
        end
      end

      def permits
        []
      end

      def hash_params
        @hash_params ||= params.require(:items).map(&:to_hash)
      end

      def items
        [
          hash_params.map { |i| i['id'] },
          hash_params.map do |i|
            i.select { |key, _| perms.include?(key.to_sym) }
          end
        ]
      end
    end
  end
end
