class Partner::ApplicationController < ApplicationController
  
  before_filter :require_user

  protected

  def current_partner
    current_user.partner if current_user
  end

  def require_user
    current_user_session.destroy if current_user_session unless current_partner
    super(new_partner_user_session_path, User::PARTNER)
  end
end