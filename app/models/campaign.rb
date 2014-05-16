class Campaign < ActiveRecord::Base

  SCHEDULED = "SCHEDULED"
  ACTIVE = "ACTIVE"
  PAUSED = "PAUSED"
  ERRORED = "ERRORED"
  PROCESSED = "PROCESSED"
  FINISHED_BY_DATE = "FINISHED_BY_DATE"
  FINISHED_BY_ACTION = "FINISHED_BY_ACTION"
  FINISHED_BY_BUDGET = "FINISHED_BY_BUDGET"

  AVAILABLE_STATUSES = [ACTIVE, PAUSED, SCHEDULED, FINISHED_BY_DATE,
    FINISHED_BY_ACTION, FINISHED_BY_BUDGET, PROCESSED, ERRORED]

  AVAILABLE_STATUSES_TO_UPDATE_START_DATE = [SCHEDULED]
  AVAILABLE_STATUSES_TO_UPDATE_END_DATE = [ACTIVE, SCHEDULED]

  DEFAULT_CLICK_THROUGH = 1
  VIRAL_TRAFFIC_LIMIT = 10

  validates_presence_of :name, :description, :advertiser_id
  validates_uniqueness_of :name

  belongs_to :market
  has_many :ads, :autosave => true
  has_many :posts, :through => :ads

  has_many :publishers, :class_name => "Publisher", :finder_sql =>
      proc { "SELECT DISTINCT publishers.*
              FROM publishers, publisher_facebooks, posts, ads, places
              WHERE publishers.id = publisher_facebooks.publisher_id
                AND places.publisher_facebook_id = publisher_facebooks.id
                AND posts.place_id = places.id
                AND posts.ad_id = ads.id
                AND ads.campaign_id = #{id}" }

  has_many :tracking_requests, :class_name => "TrackingRequest", :finder_sql =>
      proc { "SELECT tracking_requests.*
              FROM tracking_requests, posts, ads
              WHERE tracking_requests.post_id = posts.id
              	AND posts.ad_id = ads.id
                AND ads.campaign_id = #{id}
              ORDER BY tracking_requests.id" }

  has_many :campaign_prefered_post_times
  has_many :post_times, :through => :campaign_prefered_post_times

  validates_numericality_of :budget, :greater_than => 0
  validates_numericality_of :click_value, :greater_than_or_equal_to => 0.00

  # TODO: factory girl failed here, comment next 2 lines when run rake spec
  # TODO: find a solution how to bypass this
  #validates :market_id, :inclusion =>
  #   { :in => Market.all.map { |m| m.id }, :message => I18n.t("campaign.validate.markets_missing") }


  validates :end_date, :start_date, :presence => {:message => I18n.t("campaign.validate.end_date_before_start_date")}

  belongs_to :advertiser

  before_save :validate_dates, :validate_post_times

  validates :status,
            :presence => true,
            :inclusion => {:in => [SCHEDULED,
                                   ACTIVE,
                                   PAUSED,
                                   FINISHED_BY_DATE,
                                   FINISHED_BY_ACTION,
                                   FINISHED_BY_BUDGET,
                                   PROCESSED]}

  scope :ordered, order('campaigns.id desc')

  def self.payable_clicks
    clicks = Campaign.
      select('campaigns.id as campaign_id, COUNT(*) as qty, max(tracking_requests.created_at) as last_click_date').
      joins(:posts => :tracking_requests).merge(TrackingRequest.payable_clicks).
      group('campaigns.id, tracking_requests.status')
    clicks_hash = {}
    clicks.map { |c| clicks_hash[c['campaign_id'].to_i] = [c['qty'].to_i, c['last_click_date'].to_date] }
    clicks_hash
  end

  def states_clicks
    clicks = Campaign.
      select('COUNT(*) as qty, tracking_requests.status as status').
      joins(:posts => :tracking_requests).
      where(:id => id).
      group('tracking_requests.status')
      Hash[*clicks.map {|v| [v['status'], v['qty']] }.flatten]
  end

  def publishers_payable_clicks
    Publisher.unscoped.select('COUNT(*) AS payable_clicks_qty, publishers.*').
      joins(:publisher_facebooks => [:places => [:posts => [:tracking_requests, [:ad => :campaign]]]]).
      includes(:publisher_type).
      where('campaigns.id' => id, 'tracking_requests.status' => TrackingRequest::PAYABLE).
      group('publishers.id')
  end

  def tracking_requests_chain_by_status_for_publisher(status, publisher_id)
    if publisher_id.nil?
      tracking_requests_chain_by_status(status)
    else
      tracking_requests_chain_for_publisher(publisher_id).where('tracking_requests.status = ?', status)
    end
  end

  def tracking_requests_chain_by_status(status)
    tracking_requests_chain.where('tracking_requests.status = ?', status)
  end

  def tracking_requests_chain_for_publisher(search_param)
    unless search_param.nil?
      if search_param.to_i > 0
        tracking_requests_chain.where("publishers.id = ?", search_param)
      else
        tracking_requests_chain.where("publishers.first_name LIKE '%#{search_param}%' OR publishers.last_name LIKE '%#{search_param}%'")
      end
    else
      tracking_requests_chain
    end
  end

  def tracking_requests_chain
    TrackingRequest.
    select('tracking_requests.*, publishers.first_name as p_first,  publishers.last_name as p_last').
    joins(:post => [:ad => :campaign, :place => [:publisher_facebook => :publisher]]).
    where('campaigns.id = ? ', id)
  end

  def tracking_requests2
    TrackingRequest.joins(:posts)
  end

  def self.scheduled
    Campaign.all.select {|c| c.scheduled?}
  end

  def self.active
    Campaign.all.select {|c| c.active?}
  end

  def self.finished_by_date
    Campaign.all.select {|c| c.finished_by_date?}
  end

  def self.finished_by_action
    Campaign.all.select {|c| c.finished_by_action?}
  end

  def self.finished_by_budget
    Campaign.all.select {|c| c.finished_by_budget?}
  end

  def posts_needed
    (daily_budget / click_value).ceil.to_i
  end

  def scheduled?
    self.status == Campaign::SCHEDULED && Time.now.utc < start_date
  end

  def paused?
    self.status == Campaign::PAUSED && true
  end

  def active?
    now = Time.now.utc
    start_date <= now && now < end_date && (self.status == ACTIVE || (self.status == Campaign::SCHEDULED && activate!))
  end

  def paused_or_active?
    paused? || active?
  end

  def finished_by_date?
    status == Campaign::FINISHED_BY_DATE ||
      (Time.now.utc >= end_date && finishable_by_date_status? && finish_by_date)
  end

  def finished_by_action?
    status == Campaign::FINISHED_BY_ACTION &&
      (Time.now.utc < end_date || !finish_by_date)
  end

  def finished_by_budget?
    status == Campaign::FINISHED_BY_BUDGET &&
      (Time.now.utc < end_date || !finish_by_date)
  end

  def has_pending_amount?
    active? || finished_by_action? || finished_by_budget? || finished_by_date?
  end

  def has_pending_amount_over? percent
    true if (((self.budget - self.amount) *100) / self.budget) >= percent
  end

  def processed?
    status == Campaign::PROCESSED
  end

  def processable?
    finished_by_date? || finished_by_action? || finished_by_budget?
  end

  def finishable_by_action?
    active?
  end

  def state
    if processed?
      Campaign::PROCESSED
    elsif finished_by_action?
      Campaign::FINISHED_BY_ACTION
    elsif finished_by_budget?
      Campaign::FINISHED_BY_BUDGET
    elsif finished_by_date?
      Campaign::FINISHED_BY_DATE
    elsif scheduled?
      Campaign::SCHEDULED
    elsif paused?
      Campaign::PAUSED
    elsif active?
      Campaign::ACTIVE
    else
      Campaign::ERRORED
      #raise "Campaign #{id} in invalid state."
    end
  end

  def clicks_count
    ads.inject(0) { |sum, ad| sum + ad.clicks_count }
  end

  def posts_count
    Post.where(:ad_id => Ad.where(:campaign_id => self.id)).count
  end

  def publishers_count
    publishers.length
  end

  def places_count
    ds = ActiveRecord::Base.connection.execute "
      SELECT COUNT(DISTINCT posts.place_id) AS places_count
      FROM ads
        JOIN posts ON (posts.ad_id = ads.id)
      WHERE ads.campaign_id = #{self.id}"
    ds.first["places_count"]
  end

  def amount
    self.clicks_count * self.click_value
  end

  def net_click_value( publisher )
    self.click_value * (100 - publisher.publisher_type.commission) / 100
  end

  def has_budget?
    ds = ActiveRecord::Base.connection.execute "
      SELECT (COUNT(*) + 1) * campaigns.click_value AS spent
      FROM tracking_requests, posts, ads, campaigns
      WHERE tracking_requests.post_id = posts.id
      	AND posts.ad_id = ads.id
        AND ads.campaign_id = campaigns.id
        AND campaigns.id = #{id}
        AND tracking_requests.status = 'PAYABLE'
      GROUP BY campaigns.click_value"
    ds.count == 0 || ds.first["spent"].nil? || self.budget - BigDecimal.new(ds.first["spent"]) >= 0
  end

  def finish_by_budget
    self.status = Campaign::FINISHED_BY_BUDGET
    save
  end

  def finish_by_action
    self.status = Campaign::FINISHED_BY_ACTION
    save
  end

  def activate!
    self.status = ACTIVE
    save
  end

  def clicks
    Campaign.joins(:posts => :tracking_requests).
      merge(TrackingRequest.payable_clicks).where('campaigns.id=?', id).count
  end

  def click_through
    p = posts_count
    p.zero? ? DEFAULT_CLICK_THROUGH : clicks / p
  end

  def total_clicks
    Campaign.joins(:posts => :tracking_requests).where('campaigns.id=?', id).count
  end

  def rating
    click_value * click_through
  end

  def remain_budget
    budget - spent
  end

  def remain_days
    (self.end_date - Time.new) / (24 * 3600)
  end

  def ajust_ads_dates_after_campaign_update
    ads.each do |ad|
      ad.start_date = start_date if ad.start_date < start_date
      ad.end_date = end_date if ad.end_date > end_date
    end
  end

  private

  def finishable_by_date_status?
    [Campaign::ACTIVE, Campaign::FINISHED_BY_ACTION, Campaign::FINISHED_BY_BUDGET].include? status
  end

  def finish_by_date
    self.status = Campaign::FINISHED_BY_DATE
    save
  end

  def validate_dates
    if self.end_date < self.start_date
      errors.add(:end_date, I18n.t("campaign.validate.end_date_before_start_date"))
    end
  end

  def validate_post_times
  	errors.add(:post_time_ids, I18n.t("campaign.validate.post_times_missing")) if self.post_time_ids.empty?
  end

  def spent
    clicks * click_value
  end

  def daily_budget
    remain_budget / remain_days
  end
end
