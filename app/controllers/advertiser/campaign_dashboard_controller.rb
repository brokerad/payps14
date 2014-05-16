class Advertiser::CampaignDashboardController < Advertiser::ApplicationController
  def index
    @campaign = current_advertiser.campaigns.find(params[:campaign_id])
  end
end
