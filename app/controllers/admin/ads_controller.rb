class Admin::AdsController < Admin::ApplicationController

  def index
    order_direction = params[:direction] || 'DESC'
    sort_param = get_order_by_column(params[:sort])
    @ads, @pb_clicks, @impressions = get_ads_sorted(sort_param, order_direction)
  end

  def new
    @ad = Ad.new
    generate_active_category_list
		generate_campaigns_list
  end

  def create
    @ad = Ad.new(params[:ad])

    if @ad.save
      redirect_to(admin_ads_path, :notice => t("ad.created.success"))
    else
      generate_active_category_list
      render :action => "new"
    end
  end

  def edit
    @ad = Ad.find(params[:id])
    generate_active_category_list
		generate_campaigns_list
  end

  def update
    @ad = Ad.find(params[:id])
    @ad.attributes = params[:ad]
    if @ad.save
      redirect_to admin_ads_path, :notice => I18n.t("ad.updated.success")
    else
      generate_active_category_list
      generate_campaigns_list
      render :action => "edit"
    end
  end

  def destroy
    @ad = Ad.find(params[:id])
    @ad.destroy
    redirect_to(admin_ads_path, :notice => t("ad.deleted.success"))
  end

  def approve
    @ad = Ad.find(params[:id])
    @ad.ad_state.update_attributes(:state => AdState::APPROVED)
    redirect_to admin_ads_path
  end

  def reject
    @ad = Ad.find(params[:id])
    @ad.ad_state.update_attributes(:state => AdState::REJECTED, :message => params[:message])
    redirect_to admin_ads_path
  end

  private

  # Generating categories array for drop down menu
  def generate_active_category_list
    @categories = Array.new
    Category.active_categories.each { |c| @categories << [c.name_en, c.id] }
  end

  # Generating campaigns list only ACTIVE and SCHEDULED
  def generate_campaigns_list
    @campaigns = Campaign.all.select {|c| c.scheduled? or c.active?}
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
      ads = Ad.payable_clicks_ordered(order_direction).page(params[:page])
      return ads, {}, Ad.impressions_count(ads)
    elsif sort_param == "impressions"
      ads = Ad.impressions_ordered(order_direction).page(params[:page])
      return ads, Ad.payable_click_bulk(ads), {}
    else
      if params[:filter_state].blank?
        ads = Ad.includes(:campaign, :ad_state).order("#{sort_param} #{order_direction}").page(params[:page])
      else
        ads = Ad.includes(:campaign, :ad_state).joins(:ad_state).where("ad_states.state = ?", params[:filter_state].downcase).order("#{sort_param} #{order_direction}").page(params[:page])
      end

      return ads, Ad.payable_click_bulk(ads), Ad.impressions_count(ads)
    end
  end

  # Change campaign category
  # This method respond to an AJAX call to change the category
#   def change_category
#     @ad = Ad.find(params[:ad_id])
#     @ad.category_id = params[:category_id]
#
#     respond_to do |format|
#       if @ad.save
#         format.js { @error = false }
#       else
#         format.js { @error = true }
#       end
#     end
#   end

end
