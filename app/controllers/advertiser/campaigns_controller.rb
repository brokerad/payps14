class Advertiser::CampaignsController < Advertiser::ApplicationController
  def index
    @campaigns = current_advertiser.campaigns.order(sort_condition)
  end

  def new
    @campaign = Campaign.new
    @markets = Market.all.collect {|m| [m.name, m.id]}
    @editable = @editable_end_date = true
  end

  def create
    @editable = @editable_end_date = true
    @campaign = Campaign.new(params[:campaign])
    @campaign.status = Campaign::SCHEDULED
    @campaign.advertiser = current_advertiser
    if @campaign.valid? && CampaignService.save(@campaign)
      redirect_after_success_save
    else
      @markets = Market.all.collect {|m| [m.name, m.id]}    
      render :new
    end
  end

  def edit
    @campaign = current_advertiser.campaigns.find(params[:id])
    @editable = @campaign.scheduled?
    @editable_end_date = @campaign.scheduled? || @campaign.paused_or_active?
    @markets = Market.all.collect {|m| [m.name, m.id]}
  end

  def update
    @campaign = current_advertiser.campaigns.find(params[:id])
    old_budget = @campaign.budget
    if @campaign.scheduled?
      @campaign.attributes = params[:campaign]
      update_campaign(old_budget)
    elsif @campaign.paused_or_active?
      update_status_end_date(Campaign.new(params[:campaign]))
    else
      redirect_after_success_save
    end
  end
  
  private
  
  def update_campaign(old_budget)
    if @campaign.valid? && CampaignService.update(@campaign, old_budget)
      redirect_after_success_save
    else
      redirect_to_edit_action
    end
  end
  
  def update_status_end_date(campaign)
    @campaign.update_attribute(:end_date, campaign.end_date) unless campaign.end_date.blank?
    @campaign.update_attribute(:status, campaign.status) unless campaign.status.blank?
    if @campaign.save!
      redirect_after_success_save
    else
      redirect_to_edit_action
    end
  end
  
  def redirect_after_success_save
    redirect_to advertiser_campaigns_path, :notice => I18n.t("campaign.updated.success")
  end
  
  def redirect_to_edit_action
    @markets = Market.all.collect {|m| [m.name, m.id]}
    @editable = @campaign.scheduled?
    @editable_end_date = @campaign.scheduled? || @campaign.paused_or_active?
    render :edit
  end
  
  def sort_condition
    if params[:sort].blank?
      'campaigns.created_at desc'
    else
      if params[:sort] == 'company_name'        
        "advertisers.company_name " << (params[:direction].blank? ? 'asc' : params[:direction])
      else  
        "campaigns.#{params[:sort]} " << (params[:direction].blank? ? 'asc' : params[:direction])
      end
    end
  end
end
