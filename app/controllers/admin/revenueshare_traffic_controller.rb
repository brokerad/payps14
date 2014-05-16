class Admin::RevenueshareTrafficController < Admin::ApplicationController

  #TODO: ajax call to find partner tracking urls
  def index
    if params[:partner].blank? && params[:tracking_url].blank?
      @revenue_shares = RevenueShare.all 
    elsif params[:tracking_url].blank?
      @revenue_shares = RevenueShare.joins(:tracking_url).where('tracking_urls.partner_id' => params[:partner].to_i)
    elsif params[:partner].blank?
      @revenue_shares = RevenueShare.joins(:tracking_url).where('tracking_urls.id' => params[:tracking_url].to_i)
    else
      @revenue_shares = RevenueShare.joins(:tracking_url).
        where('tracking_urls.partner_id' => params[:partner].to_i, 'tracking_urls.id' => params[:tracking_url].to_i)
    end
    @partners = Partner.joins(:tracking_urls => :revenue_share).group('partners.id')
    @tracking_urls = TrackingUrl.joins(:revenue_share)
  end

end
