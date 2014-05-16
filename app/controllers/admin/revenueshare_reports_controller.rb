class Admin::RevenueshareReportsController < Admin::ApplicationController
  def index
    @revenue_shares = RevenueShare.joins(:tracking_url)
    @revenue_shares = @revenue_shares.where('tracking_urls.partner_id' => params[:partner]) unless params[:partner].blank?
    @partners = Partner.all
  end
end
