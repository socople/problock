#
module FriendlyIdable
  extend ActiveSupport::Concern

  included do
    extend FriendlyId
    friendly_id :slug_column, use: %i[slugged finders history]

    before_update :refactor_slug!
  end

  def refactor_slug!
    return if slug.blank?
    self.slug = normalize_friendly_id(slug)
  end
end
