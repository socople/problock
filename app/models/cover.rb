#
class Cover < ApplicationRecord
  belongs_to :coverable, polymorphic: true

  ##
  # consts
  STYLES = {
    small: '640x640>',
    medium: '1024x1024>',
    large: '1360x1360>'
  }.freeze

  has_attached_file :image,
                    styles: STYLES
  validates_attachment_content_type :image, content_type: /\Aimage/

  def image_urls
    styles = self.class::STYLES.keys
    styles.push(:original)

    styles.map do |style|
      {
        style => ActionController::Base.helpers.asset_url(
          URI.decode_www_form_component(image.url(style, timestamp: false))
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

  def meta_info
    return nil unless image.present?
    {
      _:      image_urls[:original],
      width:  image_width,
      height: image_height
    }
  end
end
