class Admin::ApplicationController < ApplicationController
  layout "admin/application"

  before_filter :require_user

  def index
  end

  private

  def require_user
    no_logged_redirect_to = new_admin_user_session_path
    super(no_logged_redirect_to, User::ADMIN)
  end
end
