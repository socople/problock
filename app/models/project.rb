#
class Project < ApplicationRecord
  ##
  # Include this concern to enable csv exportation on Latte for this model
  # Don't forget define exportable_fields method in controller
  include CsvExportable

  ##
  # Include this concern to enable version control on Latte for this model
  include Versionable

  ##
  # Include this concern to enable image gallery tab on Latte for this model
  include ImageGallery

  ##
  # Include this concern to enable a main image field on Latte for this model
  # Don't forget check for the main image form partial render
  include MainImageable

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
  # Improve searches with ransack
  ransacker :name, type: :string do
    Arel.sql("UNACCENT(\"#{table_name}\".\"name\")")
  end

  scope :featured, -> { where(featured: true) }
  scope :priority, -> { order(:priority) }
end
