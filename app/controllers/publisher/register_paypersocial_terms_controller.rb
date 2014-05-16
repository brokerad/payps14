class Publisher::RegisterPaypersocialTermsController < Publisher::TermsController
  
  layout 'publisher/dashboard'
  
  protected
  
  def get_dashboard
    publisher_publisher_dashboard_path
  end
  
end
