#
class ContactPolicy < ApplicationPolicy
  def create?
    false
  end
end
