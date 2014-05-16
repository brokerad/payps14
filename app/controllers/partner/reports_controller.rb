class Partner::ReportsController < Partner::ApplicationController

  def tracking_urls
    @tracking_urls = current_partner.tracking_urls
  end

  def rs_conditions
    @revenue_shares = current_partner.revenue_shares.includes(:tracking_url)
  end

  def rs_traffic
    @revenue_shares = current_partner.revenue_shares.joins(:tracking_url).includes(:tracking_url)
  end

  def publishers
    @publishers = current_partner.publishers.select{|p| p.engaged?}
  end

end