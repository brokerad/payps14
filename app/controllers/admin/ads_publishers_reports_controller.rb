class Admin::AdsPublishersReportsController < Admin::ApplicationController
  def index
    @ad = Ad.find(params[:ad_id])
    @publishers = @ad.unique_publishers
  end
end
