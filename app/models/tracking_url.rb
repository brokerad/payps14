# => a tracking url can be either attached to coupon or partner conditions
# => name should be unique
class TrackingUrl < ActiveRecord::Base

  belongs_to :partner
  has_one :revenue_share
  has_and_belongs_to_many :coupons
  has_many :publishers
  
  validates :name, :tracking_code, :partner_id, :presence => true
  validates :name, :tracking_code, :uniqueness => true
  
  #TODO: 
  # => this does not make sense at the moment, because a lot of lead_urls are the same or empty and migration fails;
  # => un-comment following 2 validations when existing lead_urls will be unique
  # validates :lead_url, :uniqueness => true
  # validates :lead_url, :presence => true
  
  default_scope :order => 'tracking_urls.created_at desc'

  before_destroy :can_be_destroyed
  
  def self.get_available
    where("not exists (SELECT 1 FROM revenue_shares where revenue_shares.tracking_url_id = tracking_urls.id)")
  end

  def active_publishers_count
    Publisher.select('distinct(publishers.id)').
      joins(:tracking_url, :publisher_facebooks => [:places => :posts]).
      where('tracking_urls.id' => id).count
  end
  
  def engaged_publishers_count
    Publisher.unscoped.select('distinct(publishers.id)').
      joins(:tracking_url, :publisher_facebooks).
      where('tracking_urls.id = ? AND publisher_facebooks.providers like ?', id, '%facebook_post%').count
  end
  
  def payable_clicks_count
    TrackingRequest.payable_clicks.
      joins(:post => [:place => [:publisher_facebook => [:publisher => :tracking_url]]]).
      where('tracking_urls.id' => id).count
  end    
  
  private

  def can_be_destroyed
    errors[:base] << I18n.t('revenue_share.validate.tracking_url_attached') unless can_destroy = revenue_share.nil? && coupons.count == 0
    can_destroy
  end

end
