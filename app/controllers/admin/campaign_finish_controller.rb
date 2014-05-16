class Admin::CampaignFinishController < Admin::ApplicationController
  def index
    Campaign.find(params[:campaign_id]).finish_by_action
    redirect_to admin_campaign_detailed_clicks_path(params[:campaign_id])
  end
end
