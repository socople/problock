#
class ProductDecorator < Draper::Decorator
  delegate_all

  def category_id
    return '' if object.category.nil?
    object.category.name
  end
end
