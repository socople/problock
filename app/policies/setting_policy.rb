#
class SettingPolicy < ApplicationPolicy
  #
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def create?
    false
  end

  def destroy?
    false
  end
end
