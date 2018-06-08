#
module Attachments
  extend ActiveSupport::Concern

  included do
    has_many :attachments, as: :attachable

    def self.attachments?
      true
    end
  end
end
