class Advertiser::CampaignPostReportsController < Advertiser::ApplicationController
  before_filter :require_user

  def index
    @campaign = current_advertiser.campaigns.find(params[:campaign_id])
    @ad = @campaign.ads.find(params[:ad_id])
  end
end
