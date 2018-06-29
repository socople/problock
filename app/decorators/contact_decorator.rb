#
class ContactDecorator < Draper::Decorator
  delegate_all

  def created_at
    h.l object.created_at, format: :localized
  end
end
