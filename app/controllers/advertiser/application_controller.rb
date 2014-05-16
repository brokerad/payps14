class Advertiser::ApplicationController < ApplicationController
  layout "advertiser/application"

  before_filter :require_user

  def index
  end

  protected

  def current_advertiser
    Advertiser.find_by_user_id(current_user.id) if current_user
  end
  
  private

  private

  def require_user
    no_logged_redirect_to = new_advertiser_user_session_path
    super(no_logged_redirect_to, User::ADVERTISER)
  end
end
