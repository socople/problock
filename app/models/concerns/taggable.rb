#
module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggable_items, as: :taggable
    has_many :tags, through: :taggable_items

    attr_accessor :tagging
    after_save :process_tags!

    def self.taggable?
      true
    end

    scope :tagged_with, lambda { |tag|
      joins(:taggable_items, :tags)
        .where('"tags"."name" ILIKE :tag OR "tags"."slug" ILIKE :tag', tag: tag)
    }
  end

  def plain_tagging
    return tagging if tags.empty?
    tags.map(&:name).join(',')
  end

  def tagging_array
    return tags.map(&:name) if tagging.nil?
    tagging.split(',').map(&:strip)
  end

  def process_tags!
    ids = tagging_array.map { |t| Tag.where(name: t).first_or_create.id }
    ids.each { |i| taggable_items.where(tag_id: i).first_or_create }
    taggable_items.where.not(tag_id: ids).delete_all
    Tag.clear!
  end
end
