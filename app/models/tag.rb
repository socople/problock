#
class Tag < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: %i[slugged finders]

  default_scope { where(locale: I18n.locale) }

  def self.clear!
    where.not(id: TaggableItem.pluck(:tag_id)).delete_all
  end
end
