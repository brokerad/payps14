class Ad < ActiveRecord::Base
  G = "Everybody"
  PG = "Not everybody"

  DEFAULT_CLICK_THROUGH = 1

  has_many :posts
  has_many :tracking_requests, :through => :posts
  has_many :publishers, :class_name => "Publisher", :finder_sql =>
    proc {  "SELECT distinct(publishers.*)
            FROM publishers
            INNER JOIN publisher_facebooks ON (publisher_facebooks.publisher_id = publishers.id)
            INNER JOIN places ON publisher_facebooks.id = places.publisher_facebook_id
            INNER JOIN posts ON places.id = posts.place_id
            WHERE posts.ad_id = #{id}" }

  has_many :ad_has_categories
  has_many :categories, :through => :ad_has_categories
  has_and_belongs_to_many :publisher_types
  has_one :ad_state

  belongs_to :campaign

  validates_presence_of :message, :link, :link_name, :link_description, :picture_link, :publisher_type_ids

  validates_associated :campaign
  validates_presence_of :campaign

  validates_associated :categories
  validates_presence_of :categories

	validates_length_of :link, :maximum => 1024
	validates_length_of :picture_link, :maximum => 1024

  validates_presence_of :link_name, :if => Proc.new { |ad| !ad.link.to_s.empty?}

  validates :visibilityrating,
            :presence => true,
            :inclusion => { :in => [G, PG] }

  validates_with UrlExistanceValidator

  after_validation :validate_dates

  before_save :change_message


  def validate_dates
		if self.campaign
	    if self.end_date <= self.start_date
	      errors.add(:end_date, I18n.t("ad.validate.end_date_before_start_date"))
	    end
	    if self.start_date < self.campaign.start_date or self.start_date > self.campaign.end_date
	      errors.add(:start_date, I18n.t("ad.validate.start_date_invalid_range", :start_date => self.campaign.start_date, :end_date => self.campaign.end_date))
	    end
	    if self.end_date < self.campaign.start_date or self.end_date > self.campaign.end_date
	      errors.add(:end_date, I18n.t("ad.validate.end_date_invalid_range", :start_date => self.campaign.start_date, :end_date => self.campaign.end_date))
	    end
		end
  end

  def self.active_ads
    Ad.all.select { |a| a.active? }
  end

  def self.get_all_ads_with_campaings
    Ad.includes(:campaign).order('ads.start_date desc')
  end

  # This method is used to filter ads on active state and visibilityrating
  # G  = Everybody
  # PG = Not Everybody
  def self.clean_ads(ads)
    clean_ads = []
    ads.each do |ad|
    	clean_ads << ad if ad.visibilityrating != Ad::PG
    end

    return clean_ads
  end

  def self.filter_ads(publisher, category, keywords = nil, order = nil)
		if keywords.nil? or keywords.empty?
			# No Search
	    unless category.eql? :all
  	    filtered_ads = Ad.all(:include => [:campaign, :categories, :ad_state], 
  	       :conditions => ["campaigns.market_id = ? AND categories.id = ? AND ad_states.state = 'approved'", publisher.market_id, category]).select { |a| a.active? && a.campaign.has_pending_amount_over?(Campaign::VIRAL_TRAFFIC_LIMIT.to_int) && check_publisher_type(a, publisher) }
	    else
	      if order.nil?
	        filtered_ads = Ad.order("click_value DESC, ads.created_at DESC").all(:include => [:campaign, :categories, :ad_state],
            :conditions => ["campaigns.market_id = ? AND ad_states.state = 'approved' AND show_homepage = true", publisher.market_id]).select { |a| a.active? && a.campaign.has_pending_amount_over?(Campaign::VIRAL_TRAFFIC_LIMIT.to_int) && check_publisher_type(a, publisher) }
	      else
	        filtered_ads = Ad.order(order).all(:include => [:campaign, :categories, :ad_state],
	         :conditions => ["campaigns.market_id = ? AND ad_states.state = 'approved' AND show_homepage = true", publisher.market_id]).select { |a| a.active? && a.campaign.has_pending_amount_over?(Campaign::VIRAL_TRAFFIC_LIMIT) && check_publisher_type(a, publisher) }
	      end
	    end
		else
			# With Search
			# Searching keywords in => link_description, message, link_name, link_caption
	    unless category.eql? :all
					filtered_ads = Ad.all(:include => [:campaign, :categories, :ad_state],
																:conditions => ["campaigns.market_id = ? AND categories.id = ? AND ad_states.state = 'approved' AND (ads.link_description LIKE ? OR ads.message LIKE ? OR ads.link_name LIKE ? OR ads.link_caption LIKE ?)",
																  publisher.market_id, category, "%#{keywords}%", "%#{keywords}%", "%#{keywords}%", "%#{keywords}%"]).select { |a| a.active? && a.campaign.has_pending_amount_over?(Campaign::VIRAL_TRAFFIC_LIMIT) && check_publisher_type(a, publisher) }
	    else
					filtered_ads = Ad.all(:include => [:campaign, :categories, :ad_state],
																:conditions => ["campaigns.market_id = ? AND ad_states.state = 'approved' AND (ads.link_description LIKE ? OR ads.message LIKE ? OR ads.link_name LIKE ? OR ads.link_caption LIKE ?)",
																  publisher.market_id, "%#{keywords}%", "%#{keywords}%", "%#{keywords}%", "%#{keywords}%"]).select { |a| a.active? && a.campaign.has_pending_amount_over?(Campaign::VIRAL_TRAFFIC_LIMIT) && check_publisher_type(a, publisher) }
	    end
		end

    # If the publisher's age is < 18 the ads that don't pass the visibilityrating filter are removed
    if publisher.birthday.nil? or (Date.today.years_ago(18) < publisher.birthday)
			Ad.clean_ads(filtered_ads)
		else
    	filtered_ads
   	end
	end

  def self.filter_my_ads(publisher)
     @ads = Ad.filter_ads(publisher, :all).select { |a| publisher.published?(@ads, a) }
  end

  def self.auto_publish
    list_to_autopublishing.each do |ad|
      ad.available_places.sort do |a, b|
        b.click_through <=> a.click_through
      end[0...ad.campaign.posts_needed].each do |place|
        place.publisher_facebook.publish(ad, Post::AUTOPUBLISHING, place)
      end
    end
  end

  def self.impressions_count(ads)
    Impression.select('ads.id').joins(:post => :ad).where('ads.id' => ads).group('ads.id').count
  end

  def self.impressions_ordered(advertiser_id, order_direction=nil)
    Ad.select("count(impressions.id) as impressions, ads.*").
      joins("JOIN campaigns ON ads.campaign_id = campaigns.id").
      joins("LEFT JOIN posts ON posts.ad_id = ads.id").
      joins("LEFT JOIN impressions ON impressions.post_id = posts.id").
      group("ads.id").
      where("campaigns.advertiser_id = #{advertiser_id}").
      order("impressions #{order_direction || 'asc'}")
  end

  def posts_count
    Post.where(:ad_id => self.id).count
  end

  def clicks_count
    Ad.where(:id => id).joins(:posts => :tracking_requests).merge(TrackingRequest.payable_clicks).count
  end

  def self.payable_click_bulk(ads)
    Ad.select('ads.id').where(:id => ads).joins(:posts => :tracking_requests).merge(TrackingRequest.payable_clicks).group('ads.id').count
  end

  def self.payable_clicks_ordered(advertiser_id, order_direction=nil)
    Ad.select("count(tracking_requests.id) as payable_clicks, ads.*").
      joins("JOIN campaigns ON ads.campaign_id = campaigns.id").
      joins("LEFT JOIN posts ON posts.ad_id = ads.id").
      joins("LEFT JOIN tracking_requests ON tracking_requests.post_id = posts.id AND tracking_requests.status = 'PAYABLE'").
      group("ads.id").
      where("campaigns.advertiser_id = #{advertiser_id}").
      order("payable_clicks #{order_direction || 'asc'}")
  end

  def click_through
    Ad.click_through_with_param(posts_count, clicks_count)
  end

  def self.click_through_with_param(_posts_count, _clicks_count)
    (_posts_count.nil? || _posts_count == 0) ? DEFAULT_CLICK_THROUGH : (_clicks_count || 0) / _posts_count
  end

  def rating
    self.campaign.click_value * click_through
  end

  # def self.payable_clicks
    # includes(:posts).merge(Post.post_payable_clicks)
  # end

  def likes
    posts.inject(0) { |sum, post| sum + post.likes }
  end

  def comments
    posts.inject(0) { |sum, post| sum + post.comments }
  end

  def unique_publishers
    self.publishers.uniq
  end

  def self.posts_and_unique_publishers_bulk(ads)
    ads_publishers = {}
    Post.select('posts.ad_id as id, count(posts.id) as posts_count, count(distinct(publishers.id)) as pubs').
      where('posts.ad_id' => ads).
      joins(:place => [:publisher_facebook => :publisher]).
      group('posts.ad_id').
      map { |v| ads_publishers[v["id"]] = [v["pubs"], v["posts_count"]] }
    ads_publishers
  end

  def available_places
    Place.find_by_sql ["SELECT places.*
                       FROM places, publishers, publisher_facebooks
                       WHERE publisher_facebooks.publisher_id = publishers.id
                         AND publisher_facebooks.id = places.publisher_facebook_id
                         AND publishers.enabled = TRUE
                         AND places.enabled = TRUE
                         AND publishers.autopublishing = TRUE
                         AND EXISTS (SELECT 1
                                     FROM campaigns, publishers
                                       AND campaigns.market_id = publishers.market_id
                                       AND campaigns.campaign_id IN (SELECT campaign_id
                                                                            FROM ads
                                                                            WHERE id = ?))
                         AND NOT EXISTS (SELECT 1
                                         FROM posts
                                         WHERE posts.place_id = places.id
                                           AND date_trunc('hour', now()) - date_trunc('hour', posts.created_at) < (24 / places.post_limit || ' hours')::interval)
                         AND date_part('hour', now() AT TIME ZONE publishers.time_zone) IN (SELECT post_time
                                                                                            FROM campaign_prefered_post_times, ads
                                                                                            WHERE campaign_prefered_post_times.campaign_id = ads.campaign_id
                                                                                              AND ads.id =  ?)",
                       self.id,
                       self.id]
  end

  def places_count
    ds = ActiveRecord::Base.connection.execute "
      SELECT COUNT(DISTINCT place_id) AS places_count
      FROM posts
      WHERE ad_id = #{self.id}"
    ds.first["places_count"]
  end

  # This method returns the advertiser owner of the related campaign
  def advertiser
    self.campaign.advertiser
  end

  def active?
    now = Time.now.utc
    start_date <= now && now < end_date && self.campaign.active?
  end

	def finished_by_date?
   	Time.now >= end_date
	end

	def posts_with_payable_clicks
	  Post.select("count(*) as qty, posts.*").joins(:tracking_requests).
	   where("tracking_requests.status = ? and posts.ad_id = ?", TrackingRequest::PAYABLE, id).
	   group("posts.id")
	end

  private

  # issue 14
  def change_message
    self.message = '.'
  end

  def self.list_to_autopublishing
    Campaign.where(:autopublishing => true).
             select {|c| c.active?}.
             collect {|c| c.ads}.
             flatten
  end

  def self.check_publisher_type(ad, publisher)
    if ad.publisher_types.count == 0
      return true
    else
      ad.publisher_types.include?(publisher.publisher_type)
    end
  end


end
