class Publisher::ApplicationController < ApplicationController

  layout "publisher/application"

  before_filter :require_user
  before_filter :check_terms
  
  helper_method :current_publisher

  protected
  
  def current_publisher
    current_user.publisher if current_user
  end

  def check_terms
    redirect_to publisher_paypersocial_terms_path unless current_publisher.accepted_all_terms?
  end
  
  def get_login_path
    publisher_publisher_login_path
  end
  
  def require_user
    current_user_session.destroy if current_user_session unless current_publisher
    super(get_login_path, User::PUBLISHER)
  end

  def default_url_options(options={})
    { :locale => publisher_locale }
  end
  
  def set_locale
    I18n.locale = publisher_locale  
  end
  
  def publisher_locale
    @locale ||= get_publisher_locale
  end
  
  def get_publisher_locale
    if(current_publisher and current_publisher.language and current_publisher.language.translation_available?)
      locale = current_publisher.language.code
    end
    locale || I18n.default_locale
  end
  
end
