# frozen_string_literal: true
module Latte
  #
  module VersionUtilities
    extend ActiveSupport::Concern
    include ActionView::Helpers::NumberHelper

    included do
      helper_method :parsed_by_type
      helper_method :show_diff?
    end

    def show
      @version = Version.find params[:id]
      render layout: false
    end

    def attribute_type(attribute)
      @version.object_model.column_for_attribute(attribute).type
    end

    #
    def parsed_by_type(attribute, value)
      return diff_method(attribute, value) if diff_method?(attribute)

      case attribute_type(attribute)
      when :boolean  then parsed_boolean_attribute(value)
      when :date     then parsed_datetime_attribute(value)
      when :datetime then parsed_datetime_attribute(value)
      when :integer  then parsed_integer_attribute(attribute, value)
      else value
      end
    end

    #
    def show_diff?(attribute)
      return false if attachments_updated_at.include?(attribute)
      true
    end

    protected

    def diff_method(attribute, value)
      @version.item.send(
        @version.object_model.diff_methods[attribute.to_sym],
        value
      )
    end

    def diff_method?(attribute)
      @version.object_model.respond_to?(:diff_methods) &&
        @version.object_model.diff_methods.include?(attribute.to_sym)
    end

    def parsed_boolean_attribute(value)
      return t('yes') if value == true
      t('no')
    end

    def parsed_datetime_attribute(value)
      return '--' if value.blank?
      l value, format: :localized
    end

    def parsed_references_attribute(attribute, value)
      association = @version.object_model.reflections.select do |reflection|
        reflection.foreign_key == attribute
      end.keys.first

      association.camelize.constantize.find(value).send(
        association.camelize.constantize.acts_as_label
      )
    rescue
      t('deleted_record')
    end

    def human_size(number)
      number_to_human_size(number, precision: 3)
    end

    def parsed_integer_attribute(attribute, value)
      return '--' if value.blank?
      return human_size(value) if attachments_file_size.include?(attribute)
      return parsed_enum_attribute(attribute, value) if enum_attr?(attribute)
      return value unless reflection_attributes.include?(attribute)

      parsed_references_attribute(attribute, value)
    end

    def enum_attr?(attribute)
      @version.object_model.defined_enums.keys.include? attribute
    end

    def parsed_enum_attribute(attribute, value)
      t(
        value,
        scope: [
          'activerecord',
          'enum',
          @version.object_model.to_s.underscore,
          attribute.to_s.underscore
        ].join('.')
      )
    end

    def reflection_attributes
      @version.object_model.reflections.keys.map do |reflection|
        @version.object_model.reflections[reflection].foreign_key
      end
    end

    def attachments_updated_at
      @version.object_model.attachment_definitions.keys.map do |attachment|
        "#{attachment}_updated_at"
      end
    rescue
      []
    end

    def attachments_file_size
      @version.object_model.attachment_definitions.keys.map do |attachment|
        "#{attachment}_file_size"
      end
    rescue
      []
    end
  end
end
