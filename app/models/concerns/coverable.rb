#
module Coverable
  extend ActiveSupport::Concern

  included do
    has_one :cover, as: :coverable
    accepts_nested_attributes_for :cover, allow_destroy: true

    def cover
      super || build_cover
    end

    def self.cover?
      true
    end
  end
end
