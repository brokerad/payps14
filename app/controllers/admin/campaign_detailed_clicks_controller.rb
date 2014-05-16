class Admin::CampaignDetailedClicksController< Admin::ApplicationController

  before_filter :require_user
  before_filter :init_tracking_requests

  def index
  end

  def update
    new_status =
      if params[:PAY]
        TrackingRequest::PAYABLE
      elsif params[:RJC]
        TrackingRequest::REJECTED
      elsif params[:SAVE_ALL]
        params[:new_status]
      end

    redirect_after_update
    return unless new_status
    tracking_ids = params[:tracking_requests].gsub(' ', '')
    begin
      @tracking_requests_selected = TrackingRequest.update_status(@campaign, tracking_ids.split(','), new_status) unless @campaign.processed?
    rescue Exception => e
      flash[:error] = e.message
    end
  end

  private

  def redirect_after_update
    redirect_path = "#{admin_campaign_detailed_clicks_path(@campaign)}?status=#{@status}"
    redirect_path << "&page=#{@page}" unless @page.blank?
    redirect_to redirect_path
  end

  def init_tracking_requests
    @campaign = Campaign.find(params[:campaign_id])
    @clicks = @campaign.states_clicks
    @status = params[:status]
    @page = params[:page]
    search_param = params[:search].blank? ? nil : params[:search]

    @tracking_requests_all =
      if @status.blank?
        @campaign.tracking_requests_chain_for_publisher(search_param).page(@page)
      else
        @campaign.tracking_requests_chain_by_status_for_publisher(@status, search_param).page(@page)
      end
  end
end
