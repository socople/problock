#
class Page < ApplicationRecord
  #
  has_and_belongs_to_many :items
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
  # Include this concern to enable tags field on Latte for this model
  include Taggable

  ##
  # Include this concern to enable a main image field on Latte for this model
  # Don't forget check for the main image form partial render
  include MainImageable

  ##
  # Include this concern to enable a cover field on Latte for this model
  # Don't forget check for the cover form partial render
  include Coverable

  ##
  # Include this concern to enable attachments tab on Latte for this model
  include Attachments

  ##
  # Include this concern to enable (external) videos tab on Latte for this model
  include ExternalVideos

  ##
  # Include this concern to get metatags method, example: @item.metatags
  # Don't forget define acts_as_description method in the respective model
  include Metataggable

  ##
  # Include this concern to enable a custom friendly id, that allow you keep
  # secure an editable slug text input, don't forget define slug_column method
  include FriendlyIdable
  #
  def slug_column
    :name
  end

  ##
  # Globalized columns
  translates :name, :description, :content, :slug

  ##
  # Validations
  validates :name, presence: true

  ##
  # Define this method to this model appears in Latte menu
  def self.menu?
    true
  end

  ##
  # Enable multiple edition on Latte, you have to write the view and controller
  # for this, take a look to the litter example for Admins
  #
  # def self.grid?
  #   true
  # end

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
  ransacker :translations_name, type: :string do
    Arel.sql("UNACCENT(\"#{translations_table_name}\".\"name\")")
  end
end
