class Publisher::FacebookController < Publisher::ApplicationController

  layout 'publisher/facebook_app'
  
  protected

  def check_terms
    redirect_to publisher_facebook_terms_path unless current_publisher.accepted_all_terms?
  end
  
  def get_login_path
    '/auth/facebook'
  end
  
end
