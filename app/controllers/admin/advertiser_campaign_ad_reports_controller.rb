class Admin::AdvertiserCampaignAdReportsController < Admin::ApplicationController
  before_filter :require_user

  def index
    @advertiser = Advertiser.find(params[:advertiser_id])
    @campaign = @advertiser.campaigns.find(params[:campaign_id])
  end
end
