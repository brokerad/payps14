class Admin::CampaignsController < Admin::ApplicationController

  def index
    @available_advertisers = available_advertisers
    @selected_advertiser = params[:advertiser]
    
    @campaigns = 
      if @selected_advertiser.blank?
        Campaign.includes(:advertiser).where(:advertiser_id => @available_advertisers)
      else        
        Campaign.includes(:advertiser).where(:advertiser_id => @selected_advertiser)
      end.order(sort_condition)
  end

  def new
    @campaign = Campaign.new
    @editable = @editable_end_date = true
    generate_adv_and_markets_lists
  end

  def create
    @editable = @editable_end_date = true
    @campaign = Campaign.new(params[:campaign])
    @campaign.status = Campaign::SCHEDULED
    if @campaign.valid? && CampaignService.save(@campaign)
      redirect_after_success_save
    else
      generate_adv_and_markets_lists
      render :new
    end
  end

  def edit
    @campaign = Campaign.find(params[:id])
    @editable = @campaign.scheduled?
    @editable_end_date = @campaign.scheduled? || @campaign.paused_or_active?
    generate_adv_and_markets_lists
  end

  def update
    @campaign = Campaign.find(params[:id])
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
    redirect_to admin_campaigns_path, :notice => I18n.t("campaign.updated.success")
  end
  
  def redirect_to_edit_action
    generate_adv_and_markets_lists
    @editable = @campaign.scheduled?
    @editable_end_date = @campaign.scheduled? || @campaign.paused_or_active?
    render :edit
  end
  
  def generate_adv_and_markets_lists
    @advertisers = Advertiser.all.collect {|a| [a.company_name, a.id]}
    @markets = Market.all.collect {|m| [m.name, m.id]}
  end
  
  def available_advertisers
    Advertiser.all_active.inject([Advertiser.new(:company_name => Paypersocial::Constants::ALL_KEYWORD)], :<<)
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
