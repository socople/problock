#
class LatteController < ApplicationController
  include Pundit

  before_action :authenticate_admin!
  before_action :set_paper_trail_whodunnit
  before_action :set_locale
  after_filter  :set_csrf_cookie_for_ng
  #
  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def user_for_paper_trail
    admin_signed_in? ? current_admin.id : nil
  end

  def pundit_user
    current_admin
  end

  def set_locale
    I18n.locale = :es # TODO
  end

  helper_method :menu_models
  #
  def menu_models
    Rails.application.eager_load!
    ApplicationRecord.descendants.map(&:name).select do |name|
      name.constantize.respond_to?(:menu?)
    end
  end

  protected

  def verified_request?
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
  end
end
