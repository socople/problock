#
module MainImageable
  extend ActiveSupport::Concern

  included do
    has_one :main_image, as: :main_imageable
    accepts_nested_attributes_for :main_image, allow_destroy: true

    def main_image
      super || build_main_image
    end

    def self.main_image?
      true
    end
  end
end
