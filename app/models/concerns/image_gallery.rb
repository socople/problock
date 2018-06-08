#
module ImageGallery
  extend ActiveSupport::Concern

  included do
    has_many :images, -> { order(:priority) }, as: :imageable

    def self.gallery?
      true
    end
  end
end
