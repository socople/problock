#
module ExternalVideos
  extend ActiveSupport::Concern

  included do
    has_many :external_videos, -> { order(:priority) }, as: :external_videoable

    def self.external_videos?
      true
    end
  end
end
