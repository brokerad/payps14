class Publisher::UserSessionsController < ApplicationController

  layout 'publisher/dashboard'

  include UserSessions
    
  def create
    super(publisher_publisher_dashboard_path)
  end
  
  def destroy
    super(new_publisher_user_session_path)
  end

  def information
    render :layout => 'empty'
  end

end
