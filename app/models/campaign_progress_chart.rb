class CampaignProgressChart
  def initialize campaign
    @campaign = campaign
  end

  def data
    data, ads = parse_dataset(ActiveRecord::Base.connection.execute query)
    (data.empty? || ads.empty? ? nil : generate_chart_data(data, ads)).to_json
  end

  private

  def query
    "SELECT q.link_name,
            to_char(q.start_date, 'YYYY-MM-dd') AS start_date,
            to_char(q.end_date, 'YYYY-MM-dd') AS end_date,
            q.date,
            q.unique_clicks,
            campaigns.click_value * q.unique_clicks AS expected_amount
     FROM campaigns,
          (SELECT campaigns.id,
                  CASE
                  WHEN ads.created_at > campaigns.start_date THEN ads.created_at
                  ELSE campaigns.start_date
                  END AS start_date,
                  campaigns.end_date,
                  ads.link_name,
                  to_char(tracking_requests.created_at, 'YYYY-MM-dd') AS date,
                  COUNT(*) AS unique_clicks
           FROM campaigns, posts, ads, tracking_requests
           WHERE ads.campaign_id = campaigns.id
             AND posts.ad_id = ads.id
             AND tracking_requests.post_id = posts.id
             AND tracking_requests.status = '#{TrackingRequest::PAYABLE}'
             AND campaigns.id = #{@campaign.id}
           GROUP BY campaigns.id,
                    campaigns.click_value,
                    campaigns.start_date,
                    campaigns.end_date,
                    ads.link_name,
                    ads.created_at,
                    to_char(tracking_requests.created_at, 'YYYY-MM-dd')) AS q"
  end

  def parse_dataset trackings
    data = {}
    ads = {}
    trackings.to_a.each do |row|
      if !ads.has_key? row["link_name"]
        ads[row["link_name"]] = {"start_date" => calculate_ad_start_date(row["start_date"]),
                                 "end_date" => calculate_ad_end_date(row["end_date"])}
      end
      if !data.has_key? row["date"]
        data[row["date"]] = {}
      end
      data[row["date"]][row["link_name"]] = {"clicks" => row["unique_clicks"],
                                             "amount" => row["expected_amount"]}
    end
    [data, ads]
  end

  def calculate_ad_start_date ad_start_date    
     #Date.parse [ad_start_date, (Time.now.utc - 30.days).strftime("%Y-%m-%d")].max
     ad_start_date.to_date
  end

  def calculate_ad_end_date campaign_end_date
    #Date.parse [campaign_end_date, Time.now.utc.strftime("%Y-%m-%d")].min
    campaign_end_date.to_date
  end

  def generate_chart_data data, ads
    dates, clicks, amount = generate_series data, ads
    {"horizontal" => {"dates" => dates},
     "vertical" => {"clicks" => clicks,
                    "amount" => amount}}
  end

  def generate_series data, ads
    dates = generate_date_range(ads)
    clicks = {}
    amount = {}
    dates.each do |day|
      ads.each do |ad_name, ad_data|
        if !clicks.has_key? ad_name
          clicks[ad_name] = []
        end
        if !amount.has_key? ad_name
          amount[ad_name] = []
        end
        day_clicks = get_stat_data(data, ad_name, ad_data, day, "clicks")
        day_amount = get_stat_data(data, ad_name, ad_data, day, "amount")
        clicks[ad_name] << (nil ? day_clicks.nil? : day_clicks.to_i)
        amount[ad_name] << (nil ? day_amount.nil? : day_amount.to_f)
      end
    end
    calculate_totals clicks
    calculate_totals amount
    formatted_dates = dates.collect {|date| Date.parse(date).strftime "%d %b"}
    [formatted_dates, clicks, amount]
  end

  def generate_date_range ads
    start_date = ads.to_a.collect {|ad| ad[1]["start_date"]}.min
    end_date = ads.to_a.collect {|ad| ad[1]["end_date"]}.max
    (start_date..end_date).collect {|d| d.to_formatted_s}
  end

  def get_stat_data data, ad_name, ad_data, day, field
    if data.has_key?(day) && data[day].has_key?(ad_name) && data[day][ad_name].has_key?(field)
      data[day][ad_name][field]
    elsif (ad_data["start_date"]..ad_data["end_date"]).include? Time.now.utc.to_date
      0
    else
      nil
    end
  end

  def calculate_totals stats
    stats["_total"] = stats.values.transpose.collect do |day_data|
      day_data.reject {|d| d.nil?}.sum
    end
  end
end
