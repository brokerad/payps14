require 'paypersocial'
class ApplicationController < ActionController::Base
  rescue_from Exception, :with => :handle_exceptions

  include Paypersocial
  # TODO create a page and put the error in a html comment, we need to see the error message
  # rescue_from Exception, :with => :default_exception_handler
  protect_from_forgery

  helper :all
  before_filter :set_locale

  helper_method :current_user_session, :current_user

  before_filter :set_p3p_header

  def set_p3p_header
    headers['P3P'] = 'CP="ALL DSP COR CURa ADMa DEVa OUR IND COM NAV"'
  end

  def default_url_options(options={})
    { :locale => I18n.locale }
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def redirect_to_404
    redirect_to '/404.html' if Rails.env.production?
  end

  def index
  end

  protected

  def current_user_session
    unless defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    @current_user_session
  end

  def current_user
    unless defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end
    @current_user
  end

  def require_user
    require_user(root_path)
  end

  def require_user(no_logged_redirect_to, role_name=nil)
    if current_user.nil?
      failed_message = I18n.t("access.must_be_logged_in")
    elsif !current_user.role?(role_name)
      failed_message = I18n.t("access.not_authorized")
    end
    unless failed_message.to_s.empty?
      store_location
      flash[:warning] = failed_message
      redirect_to no_logged_redirect_to
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def redirect_to(options = {}, response_status = {})
    if request.xhr?
      render(:update) {|page| page.redirect_to(options)}
    else
      super(options, response_status)
    end
  end

  private

  def handle_exceptions(e)
    if Rails.env.production?
      redirect_to('/500.html')
      Rails.logger.error(Time.now.utc)
      Rails.logger.error(e.to_s)
      Rails.logger.error(e.backtrace.join("\n"))
    else
      raise(e)
    end
  end

end
