#
class Attachment < ApplicationRecord
  translates :name, :description

  belongs_to :attachable, polymorphic: true

  validates :attachment, presence: true
  validates :name, presence: true

  has_attached_file :attachment
  do_not_validate_attachment_file_type :attachment

  def as_json(options = {})
    super({ methods: %i[attachment_url extension human_size] }.merge(options))
  end

  def attachment_url
    ActionController::Base.helpers.asset_url(
      URI.decode_www_form_component(attachment.url)
    )
  end

  def human_size
    helper.number_to_human_size(attachment_file_size, precision: 2)
  end

  def extension
    ext = extension_from_mime_type
    ext = File.extname(attachment_file_name) if ext.nil?

    ext.delete('.')
  end

  def extension_from_mime_type
    Rack::Mime::MIME_TYPES.invert[attachment_content_type]
  rescue
    nil
  end

  private

  def helper
    @helper ||= Class.new do
      include ActionView::Helpers::NumberHelper
    end.new
  end
end
