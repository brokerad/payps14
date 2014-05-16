class Admin::ApCampaignsController < Admin::ApplicationController
  def index
    @campaigns = Campaign.all
  end

end
