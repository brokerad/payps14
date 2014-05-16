class Publisher::FacebookDashboardsController < Publisher::FacebookController
  
  def index
    @current_category = :all
    session[:filter_category] = @current_category
    @ads_available = Ad.filter_ads(current_publisher, @current_category)
  end
  
end