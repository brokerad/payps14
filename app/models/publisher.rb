class Publisher < ActiveRecord::Base

  # SECURITY ISSUE
  # TODO: when we will have many types of publihser (not just basic),
  # we should not permit to publisher to update his/her type from view (mass assignment issue).

  MAX_PUBLISHER_LISTED = 100
  DEFAULT_CLICK_THROUGH = 1
  PERSON = "Person"
  COMPANY = "Company"

  default_scope :order => "publishers.created_at DESC"

  #validates_presence_of :first_name
  validates_presence_of :email
  validates_presence_of :user
  validates_presence_of :publisher_type_id
  validates_format_of :news_alternative_email,
    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message =>  I18n.t("publisher.newsletter.invalid_email"),
    :if => :newsletter_options_are_correct?

  validates_inclusion_of :personality, :in => [nil, PERSON, COMPANY]
  validates_inclusion_of :admin_id, :in => [nil, User.where(:role => User::ADMIN).map {|a| a.id }].flatten
  validate :coupon_tracking_url_validator

  belongs_to :publisher_type
  belongs_to :accepted_term, :class_name => "Term", :foreign_key => "accepted_term_id"
  belongs_to :coupon
  belongs_to :tracking_url
  belongs_to :language
  belongs_to :user
  belongs_to :market
  belongs_to :admin, :class_name => "User", :foreign_key => "admin_id", :conditions => ['role = ?', User::ADMIN]

  has_many :publisher_facebooks, :dependent => :destroy
  has_many :places, :through => :publisher_facebooks, :order => "enabled DESC"
  has_many :places_enabled, :class_name => "Place", :conditions => ["enabled = ?", true], :order => "name"

  accepts_nested_attributes_for :user

  has_many :tracking_requests, :through => :posts,
           :class_name => "TrackingRequest",
           :finder_sql => proc{ ["SELECT tracking_requests.*
             FROM tracking_requests, posts, places, publisher_facebooks
             WHERE publisher_facebooks.id = places.publisher_facebook_id
               AND publisher_facebooks.publisher_id = ?
               AND posts.place_id = places.id
               AND tracking_requests.post_id = posts.id
             ORDER BY tracking_requests.id", self.id]}


 has_many :active_campaigns,
          :class_name => "Campaign",
          :finder_sql => proc { ["SELECT campaigns.*
                                  FROM campaigns
                                  WHERE id IN (SELECT ads.campaign_id
                                               FROM ads, posts, places, publisher_facebooks
                                               WHERE posts.ad_id = ads.id
                                                 AND posts.place_id = places.id
                                                 AND publisher_facebooks.id = places.publisher_facebook_id
                                                 AND publisher_facebooks.publisher_id = ?)
                                  ORDER BY campaigns.end_date", self.id]}
  # after_create :lookup_places
  before_validation :set_default_publisher_type, :on => :create
  before_validation :set_user_role

  delegate :enabled?, :enabled=, :to => :user
  delegate :partner, :to => :tracking_url, :allow_nil => true
  delegate :revenue_share, :to => :tracking_url, :allow_nil => true

  scope :incomplete, where('accepted_term_id is null')
  scope :completed, where('accepted_term_id is not null')

  def newsletter_options_are_correct?
    send_newsletters && !news_use_facebook_email
  end

  def engaged?
    !publisher_facebooks.blank? && publisher_facebooks[0].engaged?
  end

  def set_user_role
    self.user.role = User::PUBLISHER
  end

  def self.publishers_with_posts
    Publisher.select('distinct(publishers.*)').joins(:places => :posts)
  end

  def self.last_publishers_with_posts
    Publisher.joins(:places => :posts).group('publishers.id').order("publishers.created_at DESC").limit(MAX_PUBLISHER_LISTED)
  end

  def self.publishers_with_posts_amount_greater_than amount
    Publisher.select('publishers.*, SUM(campaigns.click_value) AS pending_amoun').
      joins(:places => [:posts => [:tracking_requests, [:ad => :campaign]]]).
      where('tracking_requests.status = ? AND campaigns.status != ?', 'PAYABLE', 'PROCESSED').group('publishers.id').
      having(['SUM((campaigns.click_value*(100-(SELECT commission FROM publisher_types WHERE publisher_types.id = publishers.publisher_type_id)))/100) > ?', amount])
  end

  def self.publishers_with_posts_amount_less_than amount
    Publisher.select('publishers.*, SUM(campaigns.click_value) AS pending_amount').
      joins(:places => [:posts => [:tracking_requests, [:ad => :campaign]]]).
      where('tracking_requests.status = ? AND campaigns.status != ?', 'PAYABLE', 'PROCESSED').
      group('publishers.id').
      having(['SUM((campaigns.click_value*(100-(SELECT commission FROM publisher_types WHERE publisher_types.id = publishers.publisher_type_id)))/100) < ?', amount])
  end

  def self.publishers_with_posts_amount_equal_to amount
    Publisher.select('publishers.*, SUM(campaigns.click_value) AS pending_amount').
      joins(:places => [:posts => [:tracking_requests, [:ad => :campaign]]]).
      where('tracking_requests.status = ? AND campaigns.status != ?', 'PAYABLE', 'PROCESSED').
      group('publishers.id').
      having(['SUM((campaigns.click_value*(100-(SELECT commission FROM publisher_types WHERE publisher_types.id = publishers.publisher_type_id)))/100) = ?', amount])
  end

  def self.search_by_keyword(keyword)
    if keyword.to_i > 0
      where("publishers.id = ?", keyword)
    else
      where("publishers.first_name ILIKE ? OR publishers.last_name ILIKE ? OR publishers.email ILIKE ? OR publisher_facebooks.nickname ILIKE ?", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%")
    end
  end

	def self.total_publishers
		Publisher.count
	end

	def self.total_publishers_accepted_terms
  	ActiveRecord::Base.connection.execute("
  		SELECT publishers.id
      FROM publishers
      WHERE publishers.accepted_term_id IN
        (SELECT id FROM terms WHERE enabled = TRUE ORDER BY id LIMIT 1)").count
	end

	def self.total_publishers_not_accepted_terms
  	ActiveRecord::Base.connection.execute("
  		SELECT publishers.id
      FROM publishers
      WHERE publishers.accepted_term_id NOT IN
        (SELECT id FROM terms WHERE enabled = TRUE ORDER BY id LIMIT 1)").count
	end

	def self.total_publishers_engaged
  	ActiveRecord::Base.connection.execute("
  	 SELECT publishers.*
  	 FROM publishers JOIN publisher_facebooks ON publisher_facebooks.publisher_id = publishers.id
  	 WHERE publisher_facebooks.providers LIKE '%facebook_post%'
  	   AND publishers.accepted_term_id IN
  	     (SELECT id FROM terms WHERE enabled = TRUE ORDER BY id LIMIT 1)").count
	end

  def self.all_publishers_engaged
    select_str = "publishers.id,
                  publishers.first_name,
                  publishers.last_name,
                  publishers.email,
                  publishers.accepted_term_id IN (
                    SELECT id FROM terms WHERE enabled = TRUE ORDER BY id LIMIT 1) AS accepted_last_term,
                  partners.id AS partner_id,
                  partners.name AS partner_name,
                  publishers.autopublishing,
                  publishers.created_at AS created_at,
                  users.enabled as enabled,
                  COALESCE(SUM(places.friends), 0) AS friends,
                  COALESCE(SUM(places.friends + places.fans), 0) AS total_connections"

    select(select_str).joins(:user,
      "LEFT JOIN publisher_facebooks ON publisher_facebooks.publisher_id = publishers.id
       LEFT JOIN places ON places.publisher_facebook_id = publisher_facebooks.id AND places.enabled = TRUE
       LEFT JOIN partners ON (publishers.partner_id = partners.id)
       WHERE publisher_facebooks.providers LIKE '%facebook_post%'").group('publishers.id, users.enabled, partners.id')
  end

  def self.all_publishers_not_accepted_terms
    select_str = "publishers.id,
                  publishers.first_name,
                  publishers.last_name,
                  publishers.email,
                  publishers.accepted_term_id NOT IN (
                    SELECT id FROM terms WHERE enabled = TRUE ORDER BY id LIMIT 1) AS accepted_last_term,
                  partners.id AS partner_id,
                  partners.name AS partner_name,
                  publishers.autopublishing,
                  publishers.created_at AS created_at,
                  users.enabled as enabled,
                  COALESCE(SUM(places.friends), 0) AS friends,
                  COALESCE(SUM(places.friends + places.fans), 0) AS total_connections"

    select(select_str).joins(:user,
      "LEFT JOIN publisher_facebooks ON publisher_facebooks.publisher_id = publishers.id
       LEFT JOIN places ON places.publisher_facebook_id = publisher_facebooks.id AND places.enabled = TRUE
       LEFT JOIN partners ON (publishers.partner_id = partners.id)
       WHERE publishers.accepted_term_id IN
        (SELECT id FROM terms WHERE enabled = TRUE ORDER BY id LIMIT 1)").group('publishers.id, users.enabled, partners.id')
  end

  def self.all_publishers_accepted_terms
    select_str = "publishers.id,
                  publishers.first_name,
                  publishers.last_name,
                  publishers.email,
                  publishers.accepted_term_id IN (
                    SELECT id FROM terms WHERE enabled = TRUE ORDER BY id LIMIT 1) AS accepted_last_term,
                  partners.id AS partner_id,
                  partners.name AS partner_name,
                  publishers.autopublishing,
                  publishers.created_at AS created_at,
                  users.enabled as enabled,
                  COALESCE(SUM(places.friends), 0) AS friends,
                  COALESCE(SUM(places.friends + places.fans), 0) AS total_connections"

    select(select_str).joins(:user,
      "LEFT JOIN publisher_facebooks ON publisher_facebooks.publisher_id = publishers.id
       LEFT JOIN places ON places.publisher_facebook_id = publisher_facebooks.id AND places.enabled = TRUE
       LEFT JOIN partners ON (publishers.partner_id = partners.id)
       WHERE publishers.accepted_term_id IN
        (SELECT id FROM terms WHERE enabled = TRUE ORDER BY id LIMIT 1)").group('publishers.id, users.enabled, partners.id')
  end

	def self.all_publishers_from_partner partner_id
    select_str = "publishers.id,
                publishers.first_name,
                publishers.last_name,
                publishers.email,
                publishers.accepted_term_id IN (
                  SELECT id FROM terms WHERE enabled = TRUE ORDER BY id LIMIT 1) AS accepted_last_term,
                partners.id AS partner_id,
                partners.name AS partner_name,
                publishers.autopublishing,
                publishers.created_at AS created_at,
                users.enabled as enabled,
                COALESCE(SUM(places.friends), 0) AS friends,
                COALESCE(SUM(places.friends + places.fans), 0) AS total_connections"

    select(select_str).joins(:user,
      "LEFT JOIN publisher_facebooks ON publisher_facebooks.publisher_id = publishers.id
       LEFT JOIN places ON places.publisher_facebook_id = publisher_facebooks.id AND places.enabled = TRUE
       LEFT JOIN partners ON (publishers.partner_id = partners.id)
       WHERE publishers.partner_id = #{partner_id}").group('publishers.id, users.enabled, partners.id')
	end

	def self.all_publishers_registered(start_date, end_date)
    select_str = "publishers.id,
                publishers.first_name,
                publishers.last_name,
                publishers.email,
                publishers.accepted_term_id IN (
                  SELECT id FROM terms WHERE enabled = TRUE ORDER BY id LIMIT 1) AS accepted_last_term,
                partners.id AS partner_id,
                partners.name AS partner_name,
                publishers.autopublishing,
                publishers.created_at AS created_at,
                users.enabled as enabled,
                COALESCE(SUM(places.friends), 0) AS friends,
                COALESCE(SUM(places.friends + places.fans), 0) AS total_connections"

    select(select_str).joins(:user,
      "LEFT JOIN publisher_facebooks ON publisher_facebooks.publisher_id = publishers.id
       LEFT JOIN places ON places.publisher_facebook_id = publisher_facebooks.id AND places.enabled = TRUE
       LEFT JOIN partners ON (publishers.partner_id = partners.id)
       WHERE publishers.created_at BETWEEN '#{start_date.to_s}' AND '#{end_date.to_s}'").group('publishers.id, users.enabled, partners.id')
	end

	def self.all_publishers_type(publisher_type_id)
    select_str = "publishers.id,
                  publishers.first_name,
                  publishers.last_name,
                  publishers.email,
                  publishers.accepted_term_id IN (
                    SELECT id FROM terms WHERE enabled = TRUE ORDER BY id LIMIT 1) AS accepted_last_term,
                  partners.id AS partner_id,
                  partners.name AS partner_name,
                  publishers.autopublishing,
                  publishers.created_at AS created_at,
                  users.enabled as enabled,
                  COALESCE(SUM(places.friends), 0) AS friends,
                  COALESCE(SUM(places.friends + places.fans), 0) AS total_connections"

    select(select_str).joins(:user,
      "LEFT JOIN publisher_facebooks ON publisher_facebooks.publisher_id = publishers.id
       LEFT JOIN places ON places.publisher_facebook_id = publisher_facebooks.id AND places.enabled = TRUE
       LEFT JOIN publisher_types ON (publishers.publisher_type_id = publisher_types.id)
       LEFT JOIN partners ON (publishers.partner_id = partners.id)
       WHERE publishers.publisher_type_id = #{publisher_type_id}").group('publishers.id, users.enabled, partners.id')
	end

	def self.all_publishers_for_traffic_manager(user_id)
    select_str = "publishers.id,
                publishers.first_name,
                publishers.last_name,
                publishers.email,
                publishers.accepted_term_id IN (
                  SELECT id FROM terms WHERE enabled = TRUE ORDER BY id LIMIT 1) AS accepted_last_term,
                partners.id AS partner_id,
                partners.name AS partner_name,
                publishers.autopublishing,
                publishers.created_at AS created_at,
                users.enabled as enabled,
                COALESCE(SUM(places.friends), 0) AS friends,
                COALESCE(SUM(places.friends + places.fans), 0) AS total_connections"

    select(select_str).joins(:user,
      "LEFT JOIN publisher_facebooks ON publisher_facebooks.publisher_id = publishers.id
       LEFT JOIN places ON places.publisher_facebook_id = publisher_facebooks.id AND places.enabled = TRUE
       LEFT JOIN partners ON (publishers.partner_id = partners.id)
       WHERE publishers.admin_id = #{user_id}").group('publishers.id, users.enabled, partners.id')
	end

	def self.all_publishers_from_partner_count partner_id
  	Publisher.where('partner_id = ?', partner_id).count
	end

	def self.all_publishers_registered_count(start_date, end_date)
	  	Publisher.where('created_at BETWEEN ? AND ?', start_date.to_s, end_date.to_s).count
	end

	def self.all_publishers_type_count(publisher_type_id)
	  Publisher.where("publisher_type_id = ?",publisher_type_id).count
  end

	def self.all_publishers_for_traffic_manager_count(user_id)
	  Publisher.where("admin_id = ?",user_id).count
  end

  def name
    full_name = "#{self.first_name.to_s} #{self.last_name.to_s}".strip
    full_name.blank? ? 'new' : full_name
  end

  def set_facebook_attributes(publisher_facebook)
    self.first_name  = publisher_facebook.first_name
    self.last_name   = publisher_facebook.last_name
    self.email       = publisher_facebook.email
    self.birthday   = publisher_facebook.birthday

    self.publisher_facebooks << publisher_facebook
  end

  def set_name_from_fb_account(fb_account)
    self.first_name = fb_account.first_name
    self.last_name = fb_account.last_name
    self.birthday = fb_account.birthday
    save
  end

  def set_facebook_attributes!(publisher_facebook)
    set_facebook_attributes(publisher_facebook)
    save
  end

  def publish(ad, msg=nil)
    self.publisher_facebooks.each do | connection |
      connection.publish(ad, Post::MANUAL, nil, msg)
    end
  end

  def published? ads, ad
    @published_posts_by_add ||= Post.select(:ad_id).
      joins(:place => [:publisher_facebook => :publisher]).
      where(:ad_id => ads, 'publisher_facebooks.publisher_id' => self.id).map{|p| p.ad_id}
    @published_posts_by_add.include?(ad.id)
  end

  def unique_clicks_by_ad ad
    TrackingRequest.count_by_sql ["SELECT COUNT(*)
                                   FROM posts, places, tracking_requests, publisher_facebooks
                                   WHERE posts.place_id = places.id
                                   	 AND tracking_requests.post_id = posts.id
                                   	 AND places.publisher_facebook_id = publisher_facebooks.id
                                     AND tracking_requests.status = ?
                                     AND posts.ad_id = ?
                                     AND publisher_facebooks.publisher_id = ?",
                                  TrackingRequest::PAYABLE,
                                  ad.id,
                                  self.id]
  end

  def unique_clicks_by_campaign(campaign)
    TrackingRequest.count_by_sql ["SELECT COUNT(*)
                                   FROM ads, posts, places, tracking_requests, publisher_facebooks
                                   WHERE posts.ad_id = ads.id
                                     AND posts.place_id = places.id
																		 AND tracking_requests.post_id = posts.id
																		 AND places.publisher_facebook_id = publisher_facebooks.id
                                     AND tracking_requests.status = ?
                                     AND ads.campaign_id = ?
                                     AND publisher_facebooks.publisher_id = ?",
                                  TrackingRequest::PAYABLE,
                                  campaign.id,
                                  self.id]
  end

  def accepted_term?
    !self.accepted_term.nil?
  end

  def clean_commission(amount)
    commission = PublisherType.where('id=?',self.publisher_type.id).first["commission"]
    (amount*(100-commission))/100
  end

  def pending_amount
    ds = ActiveRecord::Base.connection.execute "
      SELECT SUM(campaigns.click_value) AS pending_amount
      FROM places
        JOIN publisher_facebooks ON places.publisher_facebook_id = publisher_facebooks.id
        JOIN posts ON posts.place_id = places.id
        JOIN ads ON posts.ad_id = ads.id
        JOIN campaigns ON ads.campaign_id = campaigns.id
        JOIN tracking_requests ON tracking_requests.post_id = posts.id
      WHERE tracking_requests.status = 'PAYABLE'
        AND campaigns.status <> 'PROCESSED'
        AND publisher_facebooks.publisher_id = #{self.id}"
    if ds.first and ds.first["pending_amount"]
      pa = BigDecimal.new ds.first["pending_amount"]
      clean_commission(pa)
    else
      0
    end
  end

  #note: 13 = publisher checking account
  def earned_amount
    ds = ActiveRecord::Base.connection.execute "
      SELECT SUM(entries.amount) AS earned_amount
      FROM accounts
        JOIN entries ON entries.account_id = accounts.id
      WHERE accounts.parent_id = 13
        AND accounts.name = '#{self.id}'"
    if ds.first and ds.first["earned_amount"].to_i > 0
      ea =BigDecimal.new ds.first["earned_amount"]
    else
      0
    end
  end

  def processing_amount
    withdrawals_account = BillingService.new.publisher_withdrawals_account self
    unreconciled_entries = withdrawals_account.unreconciled_entries
    unreconciled_entries.empty? ? 0 : unreconciled_entries.map {|e| e.amount}.sum
  end

  attr_accessor :processing_amount_val, :request_payment_date_val

  def request_payment_date
    withdrawals_account = BillingService.new.publisher_withdrawals_account self
    unreconciled_entries = withdrawals_account.unreconciled_entries
    unreconciled_entries.empty? ? nil : unreconciled_entries.first.created_at
  end

  def cashed_amount
    account = BillingService.new.publisher_withdrawals_account self
    account.cashed_entries.collect {|e| e.amount}.sum.abs
  end

  def credited_amount
    account = BillingService.new.publisher_withdrawals_account self
    account.credit_entries.collect {|e| e.amount}.sum.abs
  end

  #TODO: it is hardcoded, needs a refactor
  def pending_amount_per_campaign(campaign)
    ds = ActiveRecord::Base.connection.execute "
      SELECT SUM(campaigns.click_value) AS pending_amount
      FROM places
        JOIN publisher_facebooks ON places.publisher_facebook_id = publisher_facebooks.id
        JOIN posts ON posts.place_id = places.id
        JOIN ads ON posts.ad_id = ads.id
        JOIN campaigns ON ads.campaign_id = campaigns.id
        JOIN tracking_requests ON tracking_requests.post_id = posts.id
      WHERE tracking_requests.status = 'PAYABLE'
        AND campaigns.status <> 'PROCESSED'
        AND publisher_facebooks.publisher_id = #{self.id}
        AND campaigns.id = #{campaign.id}
      GROUP BY publisher_facebooks.publisher_id"
    if ds.first and ds.first["pending_amount"]
      pa = BigDecimal.new ds.first["pending_amount"]
      clean_commission(pa)
    else
      0
    end
  end

  #TODO: it is hardcoded, needs a refactor
  def earned_amount_per_campaign campaign
    ds = ActiveRecord::Base.connection.execute "
      SELECT SUM(entries.amount) AS earned_amount
      FROM accounts
        JOIN entries ON entries.account_id = accounts.id
        JOIN transactions ON entries.transaction_id = transactions.id
      WHERE accounts.parent_id = 13
        AND accounts.name = '#{self.id}'
        AND transactions.description LIKE 'Processed campaign #{campaign.id}'"
    if ds.first and ds.first["earned_amount"]
      ea = BigDecimal.new ds.first["earned_amount"]
    else
      0
    end
  end

  def pending_amount_per_ad ad
    pa = ad.campaign.click_value * unique_clicks_by_ad(ad)
    clean_commission(pa)
  end

  def billable?
    if self.publisher_type and self.earned_amount > 0
    	if self.coupon && is_coupon_available?
    		self.earned_amount >= self.publisher_type.minimal_payment + self.coupon.amount
    	else
    		self.earned_amount >= self.publisher_type.minimal_payment
    	end
    end
  end

  def ready_for_billing?
    !self.paypal.blank?
  end

  def payable_campaigns
    CampaignService.payable_campaigns self
  end

  def accepted_current_term?
    self.accepted_term == Term.current_enabled_term
  end

  def filled_mandatory_data?
    self.language_id && self.market_id && !self.time_zone.blank?
  end

  def posts_qty_per_campaign campaign
    Post.joins(:place => :publisher_facebook).
      where('publisher_facebooks.publisher_id = ? AND posts.ad_id IN (?)', self.id, Ad.select(:id).where(:campaign_id => campaign.id)).count
  end

  def posts_qty_per_ad ad
    Post.joins(:place => :publisher_facebook).
      where('publisher_facebooks.publisher_id = ? AND posts.ad_id = ?', self.id, ad.id).count
  end

  def posts_count
    Post.joins(:place => :publisher_facebook).
      where('publisher_facebooks.publisher_id = ?', self.id).count
  end

  def posts_count_per_campaign_id campaign_id
    Post.joins(:place, :ad).where('places.publisher_id = ? AND ads.campaign_id = ?', self.id, campaign_id).count
  end

  def places_count
    self.places.count
  end

  def clicks_count
    ds = TrackingRequest.find_by_sql "
      SELECT COUNT(*) AS qty
      FROM places
        JOIN publisher_facebooks ON places.publisher_facebook_id = publisher_facebooks.id
        JOIN posts ON posts.place_id = places.id
        JOIN tracking_requests ON tracking_requests.post_id = posts.id
      WHERE tracking_requests.status = 'PAYABLE'
        AND publisher_facebooks.publisher_id = #{self.id}"
    ds.first["qty"]
  end

  def clicks_count_per_campaign_id campaign_id
    ds = TrackingRequest.find_by_sql "
      SELECT COUNT(*) AS qty
      FROM places
        JOIN posts ON posts.place_id = places.id
        JOIN ads ON posts.ad_id = ads.id
        JOIN tracking_requests ON tracking_requests.post_id = posts.id
      WHERE tracking_requests.status = 'PAYABLE'
        AND ads.campaign_id = #{campaign_id}
        AND places.publisher_id = #{self.id}"
    ds.first["qty"]
  end

  def impressions_count_per_campaign_id campaign_id
    ds = Impression.find_by_sql "
      SELECT COUNT(*) AS qty
      FROM impressions
        JOIN posts ON impressions.post_id = posts.id
        JOIN places ON posts.place_id = places.id
        JOIN ads ON posts.ad_id = ads.id
      WHERE ads.campaign_id = #{campaign_id}
        AND places.publisher_id = #{self.id}"
    ds.first["qty"]
  end

  def click_through
    p = posts_count
    p.zero? ? DEFAULT_CLICK_THROUGH : clicks_count.to_i / p
  end

  def ads_published_count
    ds = ActiveRecord::Base.connection.execute "
      SELECT COUNT(*) AS qty
      FROM ads
      WHERE id IN (SELECT posts.ad_id
                   FROM posts
                   JOIN places ON (posts.place_id = places.id)
                   JOIN publisher_facebooks ON places.publisher_facebook_id = publisher_facebooks.id
                   WHERE publisher_facebooks.publisher_id = #{self.id})"
    ds.first["qty"]
  end

  def self.publishers_details(keyword)
    select_str = "publishers.id,
                  publishers.first_name,
                  publishers.last_name,
                  publishers.email,
                  publishers.accepted_term_id IN (
                    SELECT id FROM terms WHERE enabled = TRUE ORDER BY id LIMIT 1) AS accepted_last_term,
                  partners.id AS partner_id,
                  partners.name AS partner_name,
                  publishers.autopublishing,
                  publishers.created_at AS created_at,
                  users.enabled as enabled,
                  COALESCE(SUM(places.friends), 0) AS friends,
                  COALESCE(SUM(places.friends + places.fans), 0) AS total_connections"
    select(select_str).joins(:user,
      "LEFT JOIN publisher_facebooks ON publisher_facebooks.publisher_id = publishers.id
       LEFT JOIN places ON places.publisher_facebook_id = publisher_facebooks.id AND places.enabled = TRUE
       LEFT JOIN tracking_urls ON (publishers.tracking_url_id = tracking_urls.id)
       LEFT JOIN partners ON (tracking_urls.partner_id = partners.id)").
       group('publishers.id, users.enabled, partners.id').search_by_keyword(keyword)
  end

  def self.publishers_details_count(keyword)
    ds = ActiveRecord::Base.connection.execute(
      "select count(*) as qty from (#{Publisher.publishers_details(keyword).to_sql} ) as count_rows")
    ds.first["qty"].to_i
  end

  def accepted_all_terms?
    accepted_current_term? && filled_mandatory_data?
  end

  def connections
    total = 0
    publisher_facebooks.each do |fb|
      fb.places.each do |place|
        total = total + place.friends if place.enabled && place.friends != nil
      end
    end
    total
  end

  def friends
    publisher_facebooks.blank? ? 0 : publisher_facebooks[0].friends
  end

  def inform_partner?
    !is_partner_informed && accepted_term && partner && !partner.lead_url.blank?
  end

  def set_partner_as_informed
    update_attribute(:is_partner_informed, true)
  end

  def add_tracking_url_by_tracking_code(tracking_code)
    return if tracking_code.blank? || tracking_url
    t_url = TrackingUrl.where(:tracking_code => tracking_code).first
    update_attribute(:tracking_url_id, t_url.id) if t_url && t_url.active
  end

  def self.get_fb_account(publishers)
    PublisherFacebook.where(:publisher_id => publishers)
  end

  def get_eligible_time_interval(campaign)
    if is_profit_sharing_eligible? && is_campaign_profit_sharing_eligible?(campaign)
      Paypersocial::TimeInterval::TimeIntervalExtractor.extract(
        [engage_date, engage_date + revenue_share.duration.days],
        [campaign.start_date, campaign.end_date])
    end
  end

  def get_partner_payable_clicks(campaign)
    time_interval = get_eligible_time_interval(campaign)
    clicks = time_interval ? get_payable_clicks_for_time_interval(campaign, time_interval) : 0
  end

  def revenue_share_revenue
    revenue_share ? revenue_share.revenue : 0
  end

  private

  def is_coupon_available?
    processing_amount == 0 && cashed_amount == 0
  end

  def set_default_publisher_type
    self.publisher_type = PublisherType.get_default
  end

  def coupon_tracking_url_validator
    errors[:coupon] << I18n.t('revenue_share.validate.tracking_url_when_coupon') if coupon && tracking_url.blank?
    errors[:coupon] << I18n.t('revenue_share.validate.tracking_url_same_as_for_coupon') if is_coupons_tracking_url_different?
  end

  def is_coupons_tracking_url_different?
    coupon && tracking_url && !coupon.tracking_urls.include?(tracking_url)
  end

  # start REVENUE SHARE methods #
  #                             #
  def is_profit_sharing_eligible?
    revenue_share && revenue_share.active && is_engage_date_profit_sharing_eligible?
  end

  def is_engage_date_profit_sharing_eligible?
    engage_date && revenue_share &&
    (revenue_share.start_date.to_i..revenue_share.end_date.to_i).include?(engage_date.to_i)
  end

  def is_campaign_profit_sharing_eligible?(campaign)
    campaign.start_date < revenue_share.end_date
  end

  def get_payable_clicks_for_time_interval(campaign, time_inverval)
    TrackingRequest.payable_clicks.joins(:post => [:ad, {:place => :publisher_facebook}]).
      where('publisher_facebooks.publisher_id = ? AND ads.campaign_id = ? AND
             tracking_requests.created_at between ? AND ?',
             id, campaign.id, time_inverval.start_time, time_inverval.end_time).count
  end
  #                           #
  # end REVENUE SHARE methods #

end
