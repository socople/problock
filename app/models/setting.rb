#
class Setting < ApplicationRecord
  include Versionable

  translates :app_title, :app_description

  validates :km_price, presence: true,
                       numericality: {
                         greater_than: 0.0
                       }

  validates :km_extra_price, presence: true,
                             numericality: {
                               greater_than: 0.0
                             }

  ##
  # Gimmick paperclip
  has_attached_file :gimmick,
                    styles: { original: '1200x628#' }
  validates_attachment_content_type :gimmick, content_type: /\Aimage/
  attr_accessor :delete_gimmick
  before_validation { self.gimmick = nil if delete_gimmick == '1' }

  ##
  # Favicon paperclip
  has_attached_file :favicon,
                    styles: { original: '128x128#' }
  validates_attachment_content_type :favicon, content_type: /\Aimage/
  attr_accessor :delete_favicon
  before_validation { self.favicon = nil if delete_favicon == '1' }

  def self.instance
    first || new
  end

  # rubocop:disable MethodMissing
  #
  def self.method_missing(method, *params)
    return instance.send(method, *params) if instance.methods.include?(method)
    super
  end

  def gimmick_url
    ActionController::Base.helpers.asset_url(
      URI.decode_www_form_component(gimmick.url(:original, timestamp: false))
    )
  end

  def self.acts_as_label
    :name
  end

  after_gimmick_post_process :save_gimmick_dimensions
  #
  def save_gimmick_dimensions
    return if errors.any?

    geo = Paperclip::Geometry.from_file(gimmick.queued_for_write[:original])
    self.gimmick_width  = geo.width.to_i
    self.gimmick_height = geo.height.to_i
  end

  def gimmick_meta_info
    return nil unless gimmick.present?

    {
      _:      gimmick_url,
      width:  gimmick_width,
      height: gimmick_height
    }
  end

  def meta_image_url
    i = gimmick_meta_info
    return nil if i.nil? || !i.key?(:_)

    i[:_]
  end

  def favicon_meta_info
    return nil unless favicon.present?
    [
      'shortcut icon',
      'apple-touch-icon',
      'apple-touch-icon-precomposed'
    ].map do |rel|
      { href: favicon.url(:original, timestamps: false),
        sizes: '128x128',
        type: favicon_content_type, rel: rel }
    end
  end

  def metatags
    {
      charset: 'utf-8',
      viewport: 'width=device-width, initial-scale=1, maximum-scale=1, ' \
                'user-scalable=no, minimal-ui',
      'apple-mobile-web-app-capable' => 'yes', title: app_title,
      description: app_description, image_src: meta_image_url,
      icon: favicon_meta_info, og: og_metatags
    }
  end

  def og_metatags
    {
      title:       app_title,
      description: app_description,
      image:       gimmick_meta_info
    }
  end
end
