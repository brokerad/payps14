class Admin::TrackingUrlsController < Admin::ApplicationController

  def index
    @tracking_urls = TrackingUrl.includes(:partner, :coupons, :revenue_share)
    @tracking_urls = @tracking_urls.where('partners.id' => params[:search]) unless params[:search].blank?
    @partners = Partner.all
  end

  def new
    @tracking_url = TrackingUrl.new
  end

  def edit
    @tracking_url = TrackingUrl.find(params[:id])
    @coupons = Coupon.where(:partner_id => @tracking_url.partner_id, :active => true)
    @tracking_url.coupons.each { |c| @coupons << c unless @coupons.include?(c) }
  end

  def create
    @tracking_url = TrackingUrl.new(params[:tracking_url])
    respond_to do |format|
      if @tracking_url.save
        format.html { redirect_to(admin_tracking_urls_path, :notice => 'Tracking url was successfully created.') }
      else
        render :new
      end
    end
  end

  def update
    @tracking_url = TrackingUrl.find(params[:id])
    params[:tracking_url][:coupons] ||= []
    respond_to do |format|
      if @tracking_url.update_attributes(params[:tracking_url])
        format.html { redirect_to(admin_tracking_urls_path, :notice => 'Tracking url was successfully updated.') }
      else
        @coupons = Coupon.where(:partner_id => @tracking_url.partner_id, :active => true)
        @tracking_url.coupons.each { |c| @coupons << c unless @coupons.include?(c) }
        render :edit
      end
    end
  end

  def destroy
    @tracking_url = TrackingUrl.find(params[:id])
    @tracking_url.destroy
    flash[:error] = @tracking_url.errors.values[0][0] if @tracking_url.errors.count > 0
    respond_to do |format|
      format.html { redirect_to(admin_tracking_urls_path) }
    end
  end
end
