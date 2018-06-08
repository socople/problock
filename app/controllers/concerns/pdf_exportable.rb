#
module PdfExportable
  extend ActiveSupport::Concern

  included do
    respond_to :pdf
  end

  def item_for_pdf
    nil
  end

  def show
    respond_to do |format|
      format.html { super }
      format.pdf  { respond_to_pdf(item_for_pdf) }
    end
  end

  def respond_to_pdf(item)
    return if item.nil?
    pdf = InformationStandardPdf.new item, exportable_fields, view_context
    send_data pdf.render,
              filename: "#{item.acts_as_label}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
  end
end
