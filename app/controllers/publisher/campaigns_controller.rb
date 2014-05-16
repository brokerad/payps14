class Publisher::CampaignsController < Publisher::ApplicationController
  def index
    @campaigns = current_publisher.active_campaigns
    @publisher = current_publisher
  end
end
