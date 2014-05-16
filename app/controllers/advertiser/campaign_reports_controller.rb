class Advertiser::CampaignReportsController < Advertiser::ApplicationController
  before_filter :require_user

  def index
    @campaigns = current_advertiser.campaigns
  end
end
