class Admin::AdsReportsController < Admin::ApplicationController
  before_filter :require_user
  def index
    if params[:filter_traffic_manager] && !params[:filter_traffic_manager].blank?
      @current_traffic_manager = User.find(params[:filter_traffic_manager])
      @ads = @current_traffic_manager.active_ads.page params[:page]
    else
      @ads = Ad.get_all_ads_with_campaings.page params[:page]
    end
    @pb_clicks = Ad.payable_click_bulk(@ads)
    @pubs_and_posts_count = Ad.posts_and_unique_publishers_bulk(@ads)
    @traffic_managers = User.where("role LIKE '%admin%'")
  end
end
