# frozen_string_literal: true
module Latte
  #
  module CsvExportable
    extend ActiveSupport::Concern

    included do
      respond_to :csv
    end

    def index
      respond_to do |format|
        format.html { super }
        format.json { super }
        format.csv  { respond_to_csv }
      end
    end

    def respond_to_csv
      @q = policy_scope(model).ransack(params[:filter])
      @i = @q.result.paginate(page: params[:page], per_page: params[:count])

      send_data(*csv_meta_data)
    end

    def csv_meta_data
      [
        @q.result.to_csv(exportable_fields),
        filename: csv_filename,
        type: 'text/csv; charset=iso-8859-1; header=present'
      ]
    end

    def csv_filename
      t(model.to_s.underscore, scope: 'activerecord.models', count: :many) +
        ' ' + l(Time.zone.now, format: :timestamp) +
        '.csv'
    end
  end
end
