# rubocop:disable LineLength
#
class ExternalVideo < ApplicationRecord
  translates :name, :description

  belongs_to :external_videoable, polymorphic: true
  validates :url, presence: true
  validate  :valid_url?

  def valid_url?
    return unless provider.nil? || provider_id.nil?
    errors.add(:url, 'Debe ser válida (Youtube o Vimeo)')
  end


  def as_json(options = {})
    super({ methods: %i[provider provider_id thumbnail_url] }.merge(options))
  end

  def provider
    regex_prov = /(youtube|youtu\.be|vimeo)/
    match_prov = regex_prov.match(url)

    return nil    unless match_prov && match_prov[1].present?
    return :vimeo if match_prov[1] == 'vimeo'
    :youtube
  end

  def provider_id
    regex_id = %r{(?:youtube(?:-nocookie)?\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/|vimeo\.com\/)([a-zA-Z0-9_-]{8,11})}
    match_id = regex_id.match(url)

    return nil unless match_id && match_id[1].present?
    match_id[1]
  end

  def thumbnail_url
    return vimeo_thumbnail_url if provider == :vimeo
    "https://img.youtube.com/vi/#{provider_id}/0.jpg"
  end

  def embed_url
    return "https://player.vimeo.com/video/#{provider_id}" if provider == :vimeo
    "https://www.youtube.com/embed/#{provider_id}"
  end

  def vimeo_thumbnail_url
    api_url = "http://vimeo.com/api/v2/video/#{provider_id}.json"
    JSON.parse(open(api_url).read).first['thumbnail_large']
  rescue
    nil
  end
end
