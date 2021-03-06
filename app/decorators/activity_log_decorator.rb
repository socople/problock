#
class ActivityLogDecorator < Draper::Decorator
  delegate_all

  def whodunnit
    return 'Sistema' if object.admin.nil?
    object.admin.name
  end

  def item_type
    h.t "activerecord.models.#{object.item_type.underscore}.one"
  end

  def item_id
    object.object_name
  end
end
