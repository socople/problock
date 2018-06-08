#
class Version < PaperTrail::Version
  #
  belongs_to :admin, foreign_key: :whodunnit
  before_save :set_locale

  def yobject
    return {} if object.nil?
    HashWithIndifferentAccess.new(YAML.safe_load(object, [Time]))
  end

  def object_model
    item_type.constantize
  end

  def acts_as_label
    yobject[item_type.constantize.acts_as_label]
  end

  def object_name
    return acts_as_label unless
                         changeset.key?(item_type.constantize.acts_as_label)

    changeset[object_model.acts_as_label].last
  end

  def event
    return 'rename' if
                    changeset.key?(item_type.constantize.acts_as_label) &&
                    !object.nil?
    super
  end

  def rename_or_name(separator = ' > ')
    return object_name unless event == 'rename'
    [
      reify.send(item_type.constantize.acts_as_label),
      object_name
    ].join(separator)
  end

  private

  def set_locale
    self.locale = Globalize.locale.to_s
  end
end
