class Admin::TrafficReportsController < Admin::ApplicationController
  def index
    @data = Array.new    

    to_date = Date.today.end_of_day
    from_date = Date.today.beginning_of_month.beginning_of_day
        
    total_clicks = TrackingRequest.where("created_at BETWEEN ? AND ?", from_date.to_time.utc, to_date.to_time.utc)
    payable_clicks = total_clicks.where("status = ?", TrackingRequest::PAYABLE)
    @data << {:to_date => to_date, :from_date => from_date, :total_clicks => total_clicks.count, :payable_clicks => payable_clicks.count}

    from_date = from_date.prev_month.beginning_of_month
    to_date = to_date.prev_month.end_of_month

    while (from_date.year >= 2012) do
      total_clicks = TrackingRequest.where("created_at BETWEEN ? AND ?", from_date.to_time.utc, to_date.to_time.utc)
      payable_clicks = total_clicks.where("status = ?", TrackingRequest::PAYABLE)
      @data << {:to_date => to_date, :from_date => from_date, :total_clicks => total_clicks.count, :payable_clicks => payable_clicks.count}      
      from_date = from_date.prev_month
      to_date = to_date.prev_month.end_of_month
    end
  end
end
