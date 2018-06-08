#
class Image < ApplicationRecord
  translates :description

  belongs_to :imageable, polymorphic: true

  ##
  # consts
  STYLES = {
    small: '320x320>',
    medium: '640x640>',
    large: '1024x1024>'
  }.freeze

  has_attached_file :image,
                    styles: STYLES
  validates_attachment_content_type :image, content_type: /\Aimage/

  def as_json(options = {})
    super({ methods: %i[image_urls] }.merge(options))
  end

  def image_urls
    styles = self.class::STYLES.keys
    styles.push(:original)

    styles.map do |style|
      {
        style => ActionController::Base.helpers.asset_url(
          URI.decode_www_form_component(image.url(style))
        )
      }
    end.reduce(:merge)
  end

  after_post_process :save_image_dimensions
  #
  def save_image_dimensions
    return if errors.any?

    geo = Paperclip::Geometry.from_file(image.queued_for_write[:original])
    self.image_width  = geo.width.to_i
    self.image_height = geo.height.to_i
  end
end
