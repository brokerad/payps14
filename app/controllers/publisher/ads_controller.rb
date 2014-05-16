require 'publisher/application_controller'
class Publisher::AdsController < Publisher::ApplicationController
  def index
    @campaign = Campaign.find(params[:campaign_id])
    @ads = @campaign.ads.all.first
  end

  def create
    @post = User.new(params[:post])
    @post.source = Post::MANUAL
    if @post.save
      redirect_to(publisher_ads_path, :notice => 'Ad was successfully published.')
    else
      redirect_to :index
      # render :action => "new"
    end
  end
end
