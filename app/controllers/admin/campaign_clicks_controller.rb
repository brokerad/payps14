class Admin::CampaignClicksController < Admin::ApplicationController
  before_filter :require_user

  def index
    @status = params[:status].blank? ? Campaign::ACTIVE : params[:status]
    @campaigns = 
    if @status == Paypersocial::Constants::ALL_KEYWORD
      Campaign.ordered.includes(:advertiser).page params[:page]
    else
      Campaign.ordered.where(:status => @status).includes(:advertiser).page params[:page]
    end 
    @payable_clicks = Campaign.where(:id => @campaigns).payable_clicks
    @available_statuses = Campaign::AVAILABLE_STATUSES.inject([Paypersocial::Constants::ALL_KEYWORD], :<<)
  end
end
