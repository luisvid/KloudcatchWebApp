class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
  before_filter :set_base_user
  before_filter :require_login

  def app_path
    app_path = root_path
    app_path = account_path if current_user
    return app_path
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = t(:no_access)
    redirect_to app_path
  end

  def default_url_options(options={})
    {:locale => I18n.locale}
  end

  def set_locale
    I18n.locale = params[:locale] if params[:locale].present?
  end

  def set_base_user
    unless current_user
      @user = User.new
    end
  end

  private
  
  def not_authenticated
    flash[:warning] = I18n.t(:auth_required)
    redirect_to signin_path
  end
end
