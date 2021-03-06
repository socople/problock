#
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action { set_meta_tags Setting.metatags }

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    return latte_root_url if resource_or_scope == :admin
    super
  end

  helper_method :main_category
  #
  def main_category
    @main_category ||= Category.main.priority.first
  end

  helper_method :show_map?
  #
  def show_map?
    true
  end

  helper_method :quotation_map?
  #
  def quotation_map?
    false
  end
end
