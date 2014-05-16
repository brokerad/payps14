require 'advertiser/application_controller'
class Advertiser::AdsController < Advertiser::ApplicationController
  def index
    order_direction = params[:direction] || 'DESC'
    sort_param = get_order_by_column(params[:sort])
    @ads, @pb_clicks, @impressions = get_ads_sorted(sort_param, order_direction)
  end

  def new
    @ad = Ad.new
    @campaigns = current_advertiser.campaigns.where("end_date > ?", current_utc_time)
    generate_active_category_list
		generate_campaigns_list
  end

  def create
    @ad = Ad.new(params[:ad])
    @ad.build_ad_state
    if @ad.save
      redirect_to(advertiser_ads_path, :notice => t("ad.created.success"))
    else
      @campaigns = current_advertiser.campaigns.where("end_date > ?", current_utc_time)
      generate_active_category_list
      render :action => "new"
    end
  end

  def edit
    @ad = current_advertiser.ads.find(params[:id])
    generate_active_category_list
		generate_campaigns_list
  end

  def update
    @ad = Ad.joins(:campaign).where(:id => params[:id], 'campaigns.advertiser_id' => current_advertiser.id).readonly(false).first
    @ad.attributes = params[:ad]
    if @ad.save
      @ad.ad_state.update_attributes(:state => AdState::PENDING, :message => nil)
      redirect_to advertiser_ads_path, :notice => I18n.t("ad.updated.success")
    else
      generate_active_category_list
      generate_campaigns_list
      render :action => "edit"
    end
  end

  def destroy
    @ad = current_advertiser.ads.find(params[:id])
    @ad.destroy
    redirect_to(advertiser_ads_path, :notice => t("ad.deleted.success"))
  end

  private

  def generate_active_category_list
    @categories = Array.new
    Category.active_categories.each { |c| @categories << [c.name_en, c.id] }
  end

  def generate_campaigns_list
    @campaigns = Campaign.where("advertiser_id = ?", current_advertiser.id).select {|c| c.scheduled? or c.active?}
  end

  def get_order_by_column(sort_param)
    get_column_name[sort_param] || get_special_column_name[sort_param] || 'ads.start_date'
  end

  def get_column_name
    { 'message' => 'link_name',
      'link' => 'link_caption',
      'campaign' => 'campaigns.name',
      'visibility' => 'visibilityrating' }
  end

  def get_special_column_name
    { 'clicks' => 'payable_clicks',
      'impressions' => 'impressions'}
  end

  def get_ads_sorted(sort_param, order_direction)
    if sort_param == "payable_clicks"
      ads = Ad.payable_clicks_ordered(current_advertiser.id, order_direction).page(params[:page])
      return ads, {}, Ad.impressions_count(ads)
    elsif sort_param == "impressions"
      ads = Ad.impressions_ordered(current_advertiser.id, order_direction).page(params[:page])
      return ads, Ad.payable_click_bulk(ads), {}
    else
      ads = Ad.includes(:campaign).where("campaigns.advertiser_id = ?", current_advertiser.id).order("#{sort_param} #{order_direction}").page(params[:page])
      return ads, Ad.payable_click_bulk(ads), Ad.impressions_count(ads)
    end
  end
end
