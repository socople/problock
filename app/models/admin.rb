#
class Admin < ApplicationRecord
  rolify
  include CsvExportable
  include Versionable

  has_one :admin_setting

  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :lockable

  validates :name, presence: true

  validates :email, presence: true
  validates :email,
            uniqueness: { case_sensitive: false },
            if: proc { |o| o.email.present? }

  validates :email,
            format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i },
            if: proc { |o| o.email.present? }

  validates :password,
            presence: true,
            confirmation: true,
            on: :create

  validates :password,
            presence: true,
            confirmation: true,
            if: proc { |o| o.password.present? },
            on: :update

  def self.menu?
    true
  end

  def self.grid?
    true
  end

  def self.acts_as_label
    :name
  end
end
