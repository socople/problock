#
module CsvExportable
  extend ActiveSupport::Concern

  included do
    require 'csv'
  end

  #
  module ClassMethods
    def csv_header(fields)
      fields.map do |f|
        I18n.t "activerecord.attributes.#{name.underscore}.#{f}"
      end
    end

    def collection
      where(nil).decorate
    rescue
      where(nil)
    end

    def bom
      "\xEF\xBB\xBF"
    end

    def csv_options
      { headers: true, force_quotes: true, encoding: 'utf-8' }
    end

    def to_csv(*fields)
      fields = fields.first if fields.first.is_a? Array

      CSV.generate(bom.dup, csv_options) do |csv|
        csv << csv_header(fields)
        collection.each do |o|
          csv << fields.map { |f| o.try(f) || '' }
        end
      end
    end
  end
end
