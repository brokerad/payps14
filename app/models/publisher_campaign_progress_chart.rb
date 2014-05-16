class PublisherCampaignProgressChart < CampaignProgressChart
  def initialize campaign, publisher
    super campaign
    @publisher = publisher
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
           FROM campaigns, posts, places, publisher_facebooks, ads, tracking_requests
           WHERE ads.campaign_id = campaigns.id
             AND posts.ad_id = ads.id
             AND posts.place_id = places.id
             AND tracking_requests.post_id = posts.id
             AND publisher_facebooks.id = places.publisher_facebook_id
             AND tracking_requests.status = '#{TrackingRequest::PAYABLE}'
             AND campaigns.id = #{@campaign.id}
             AND publisher_facebooks.publisher_id = #{@publisher.id}
           GROUP BY campaigns.id,
                    campaigns.click_value,
                    campaigns.start_date,
                    campaigns.end_date,
                    ads.link_name,
                    ads.created_at,
                    to_char(tracking_requests.created_at, 'YYYY-MM-dd')) AS q"
  end
end
