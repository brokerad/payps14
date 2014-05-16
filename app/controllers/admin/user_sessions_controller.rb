class Admin::UserSessionsController < Admin::ApplicationController
  before_filter :require_user, :only => :destroy

  layout "admin/user_sessions/application"

  include UserSessions

  def create
    super(admin_root_path)
  end

  def destroy
    super(new_admin_user_session_path)
  end
end
