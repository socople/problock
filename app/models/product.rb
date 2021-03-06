#
class Product < ApplicationRecord
  belongs_to :category
  belongs_to :quotation_category, optional: true

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
  # Validations
  validates :name, presence: true
  validates :category_id, presence: true
  validates :priority,
            numericality: {
              only_integer: true
            }
  validates :quotation_priority,
            numericality: {
              only_integer: true
            }
  validates :units_by_truck,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }
  validates :price,
            numericality: {
              greater_than: 0.0
            }

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

  scope :priority, -> { order(:priority) }
end
