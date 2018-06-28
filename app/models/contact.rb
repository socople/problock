#
class Contact < ApplicationRecord
  ##
  # Include this concern to enable csv exportation on Latte for this model
  # Don't forget define exportable_fields method in controller
  include CsvExportable

  ##
  # Validations
  validates :name, presence: true

  validates :email,
            presence: true,
            format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  validates :message, presence: true

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

  ransacker :email, type: :string do
    Arel.sql("UNACCENT(\"#{table_name}\".\"email\")")
  end

  ransacker :phone, type: :string do
    Arel.sql("UNACCENT(\"#{table_name}\".\"phone\")")
  end
end
