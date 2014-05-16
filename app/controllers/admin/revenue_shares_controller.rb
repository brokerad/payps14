class Admin::RevenueSharesController < Admin::ApplicationController

  def index
    if params[:partner].blank?
      @revenue_shares = RevenueShare.all
      @partners = Partner.all
    else
      @revenue_shares = RevenueShare.joins(:tracking_url).where("tracking_urls.partner_id = ?", params[:partner])
      @partners = Partner.all
    end
  end

  def new
    @revenue_share = RevenueShare.new
    @partners = Partner.all
    if params[:partner].blank?
      @traking_urls = TrackingUrl.get_available
    else
      all_traking_urls = TrackingUrl.get_available
      @traking_urls = all_traking_urls.select{|p| p.partner_id == params[:partner].to_i}
    end
  end

  def edit
   @revenue_share = RevenueShare.find(params[:id])
   @traking_urls = TrackingUrl.get_available
   @traking_urls << @revenue_share.tracking_url if @revenue_share.tracking_url
   @partners = Partner.all
  end

  def create
   @revenue_share = RevenueShare.new(params[:revenue_share])
   if @revenue_share.save
     redirect_to(admin_revenue_shares_path, :notice => 'Partner Revenue Share was successfully created.')
    else
      @traking_urls = TrackingUrl.get_available
      @partners = Partner.all
      render :action => "new"
    end
  end

  def update
   @revenue_share = RevenueShare.find(params[:id])
   if @revenue_share.update_attributes(params[:revenue_share])
     redirect_to(admin_revenue_shares_path, :notice => 'Partner Revenue Share was successfully updated.')
    else
      @traking_urls = TrackingUrl.get_available
      @traking_urls << RevenueShare.find(params[:id]).tracking_url
      @partners = Partner.all
      render :action => "edit"
    end
  end

  def destroy
   @revenue_share = RevenueShare.find(params[:id])
   @revenue_share.destroy
   redirect_to(admin_revenue_shares_path, :notice => 'Partner Revenue Share was successfully deleted.')
  end

  def timeline
    0
  end

end