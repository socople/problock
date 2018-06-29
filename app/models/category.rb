#
class Category < ApplicationRecord
  belongs_to :category

  has_many :categories

  ##
  # Include this concern to enable csv exportation on Latte for this model
  # Don't forget define exportable_fields method in controller
  include CsvExportable

  ##
  # Include this concern to enable version control on Latte for this model
  include Versionable

  ##
  # Include this concern to enable a main image field on Latte for this model
  # Don't forget check for the main image form partial render
  include MainImageable

  ##
  # Include this concern to enable a cover field on Latte for this model
  # Don't forget check for the cover form partial render
  include Coverable

  ##
  # Include this concern to enable a custom friendly id, that allow you keep
  # secure an editable slug text input, don't forget define slug_column method
  include FriendlyIdable
  #
  def slug_column
    :name
  end

  ##
  # Validations
  validates :name, presence: true
  validates :priority, numericality: { only_integer: true }

  ##
  # Define this method to this model appears in Latte menu
  def self.menu?
    true
  end

  ##
  # Don't forget this method, Latte uses it for many things
  def self.acts_as_label
    :name
  end

  ##
  # Define this method when you include Metataggable concern to choose the field
  # to show in meta description tag
  def self.acts_as_description
    :description
  end

  ##
  # Improve searches with ransack
  ransacker :name, type: :string do
    Arel.sql("UNACCENT(\"#{table_name}\".\"name\")")
  end

  scope :main,     -> { where(category_id: nil) }
  scope :featured, -> { where(featured: true) }
  scope :priority, -> { order(:priority) }

  def family
    o = [self]
    (categories.map(&:family) + o).flatten
  end

  def family_ids
    family.map(&:id)
  end

  def products
    Product.where(category_id: family_ids).priority
  end
end
