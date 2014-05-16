class Admin::CouponsController < Admin::ApplicationController

  def index
    @coupons = Coupon.includes(:tracking_urls => :partner)
    @total_used_coupons = Coupon.total_used_batch(@coupons)
  end

  def new
    @coupon = Coupon.new
    @partners = Partner.all
  end

  def create
    @coupon = Coupon.new(params[:coupon])
    if @coupon.save
      redirect_to(admin_coupons_path, :notice => t("coupon.created.success"))
    else
      @partners = Partner.all
      render :new
    end
  end

  def edit
    @coupon = Coupon.where('coupons.id' => params[:id]).first
    @tracking_urls = TrackingUrl.where(:partner_id => @coupon.partner_id, :active => true)
    @coupon.tracking_urls.each { |tu| @tracking_urls << tu unless @tracking_urls.include?(tu) }
  end

  def update
    @coupon = Coupon.find(params[:id])
    params[:coupon][:tracking_url_ids] ||= []
    if @coupon.update_attributes(params[:coupon])
      redirect_to admin_coupons_path, :notice => I18n.t("coupon.updated.success")
    else
      @tracking_urls = TrackingUrl.where(:partner_id => @coupon.partner.id, :active => true)
      @coupon.tracking_urls.each { |tu| @tracking_urls << tu unless @tracking_urls.include?(tu) }
      render :edit
    end
  end

  def destroy
    @coupon = Coupon.find(params[:id])
    @coupon.destroy
    redirect_to(admin_coupons_path, :notice => t("coupon.deleted.success"))
  end
end
