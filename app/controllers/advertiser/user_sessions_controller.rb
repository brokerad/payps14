class Advertiser::UserSessionsController < Advertiser::ApplicationController
  before_filter :require_user, :only => :destroy

  layout "advertiser/user_sessions/application"

  include UserSessions

  def create
    super(advertiser_root_path)
  end

  def destroy
    super(new_advertiser_user_session_path)
  end
end
