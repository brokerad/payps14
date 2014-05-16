class Publisher::CampaignReportsController < Publisher::ApplicationController
  def index
    @campaign = Campaign.find(params[:campaign_id])
    @publisher = current_publisher
    @chart_data = PublisherCampaignProgressChart.new(@campaign, @publisher).data
  end
end
