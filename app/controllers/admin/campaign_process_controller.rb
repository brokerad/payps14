class Admin::CampaignProcessController < Admin::ApplicationController
  def index
    begin
      campaign_id = params[:campaign_id]
      CampaignService.process Campaign.find(params[:campaign_id])
      redirect_to admin_campaigns_path
    rescue Error::PendingRequestError => error
      redirect_to_campaign_with_error(error, campaign_id)
    rescue Error::CampaignExceedBudgetError => error
      redirect_to_campaign_with_error(error, campaign_id)
    end
  end

  def reprocess
    begin
      campaign = Campaign.find(params[:campaign_id])
      reprocessed = CampaignService.reprocess_campaign(campaign)
      flash[:notice] = reprocessed ? t("campaign.reprocess.success") : t("campaign.reprocess.nothing")
      redirect_to admin_campaign_detailed_clicks_path(campaign.id)
    rescue Exception => error
      logger.error(error)
      logger.error(error.backtrace.join("\n"))
      redirect_to_campaign_with_error(error, campaign.id)
    end
  end

  private

  def redirect_to_campaign_with_error error, campaign_id
    message = "Campaign process failed"
    message << " with following error: #{error.message}" if error.message
    flash[:error] = message
    redirect_to admin_campaign_detailed_clicks_path(campaign_id)
  end

end
