class Admin::AdvertiserCampaignPostReportsController < Admin::ApplicationController
  before_filter :require_user

  def index
    @advertiser = Advertiser.find(params[:advertiser_id])
    @campaign = @advertiser.campaigns.find(params[:campaign_id])
    @ad = @campaign.ads.find(params[:ad_id])
    @publishers = @ad.unique_publishers
  end
end
