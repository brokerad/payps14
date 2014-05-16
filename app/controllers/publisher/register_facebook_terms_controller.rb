class Publisher::RegisterFacebookTermsController < Publisher::TermsController
  
  layout 'publisher/facebook_terms'
  
  protected
  
  def get_dashboard
    publisher_facebook_dashboard_path
  end
  
end