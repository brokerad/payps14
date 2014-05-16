class Advertiser::CampaignDashboardReportsController < Advertiser::ApplicationController
  before_filter :require_user

  def index
    @campaign = current_advertiser.campaigns.find(params[:campaign_id])
    @ads = @campaign.ads
    @chart_data = CampaignProgressChart.new(@campaign).data
  end
end
