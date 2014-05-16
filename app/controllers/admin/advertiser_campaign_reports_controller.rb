class Admin::AdvertiserCampaignReportsController < Admin::ApplicationController
  before_filter :require_user

  def index
    @advertiser = Advertiser.find(params[:advertiser_id])
  end
end
