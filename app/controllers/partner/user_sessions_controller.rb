class Partner::UserSessionsController < ApplicationController

  layout "partner/application"

  include UserSessions

  def create
    super(partner_root_path)
  end

  def destroy
    super(new_partner_user_session_path)
  end
end