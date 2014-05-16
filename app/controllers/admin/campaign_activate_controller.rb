class Admin::CampaignActivateController < Admin::ApplicationController
  def index
    Campaign.find(params[:campaign_id]).activate!
    redirect_to admin_campaigns_path
  end
end
