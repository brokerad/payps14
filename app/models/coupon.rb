class Coupon < ActiveRecord::Base
  
  # remove tracking_url direct relation
  # add direct relation to partner
  # add intermediate table to create relationship between tracking_url and coupon
  
  VALID = 1
  INVALID = -1
  NONACTIVE = -2
  EXPIRED = -3
  UNAVAILABLE = -4

  belongs_to :partner
  has_and_belongs_to_many :tracking_urls
  has_many :publishers
  
  validates :name, :code, :total, :amount, :partner_id, :presence => true
  validates :code, :uniqueness => true
  validates :total, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :amount, :numericality => { :greater_than_or_equal_to => 0 }
  validate :validate_tracking_url_partner
  validates_with StartAndEndDateValidator

  before_validation :check_for_publishers_validator
  before_destroy :can_be_destroyed
  
  #default_scope :order => :end_date # first listed is the first coupon will end
  default_scope :order => :partner_id

  # This method reaces from publishers how many are registered using the coupon
  def total_used
    Publisher.joins(:coupon).where('coupons.id' => id).count
  end
  
  def self.total_used_batch(coupons)
    hash = {}
    Publisher.unscoped.select('count(*) as count, coupons.id as coupon_id').
      joins(:coupon).
      where('coupons.id' => coupons).group('coupons.id').map {|c| hash[c['coupon_id']] = c['count']}
    hash
  end
  
  def active_coupon?
    Coupon.status(self) == Coupon::VALID
  end

  def has_discount?
    active_coupon? && amount > 0
  end
  
  def self.status(coupon)
    if coupon.nil?
      Coupon::INVALID
    elsif coupon.start_date >= Time.now.utc
      Coupon::NONACTIVE
    elsif coupon.end_date < Time.now.utc
      Coupon::EXPIRED
    elsif coupon.total <= coupon.total_used
      Coupon::UNAVAILABLE
    else
      Coupon::VALID
    end
  end
  
  private
  
  def validate_tracking_url_partner
    errors[:base] << I18n.t("revenue_share.validate.coupon_partner_invalid") if is_tracking_url_partner_different?
  end
  
  def is_tracking_url_partner_different?
    tracking_urls.each { |tu| return true if tu.partner_id != partner_id }
    false
  end
  
  def check_for_publishers_validator
    if publishers.count > 0
      errors[:base] << I18n.t('revenue_share.validate.coupon_update_invalid')
      # to skip updating other fields it is necessary to read clean object
      # more info: http://apidock.com/rails/v3.0.7/ActiveRecord/Persistence/update_attribute
      Coupon.find(id).update_attribute(:active, active)
    end
  end
  
  def can_be_destroyed
    errors[:base] << I18n.t('revenue_share.validate.coupon_destroy_invalid') unless can_destroy = publishers.count == 0
    can_destroy
  end
  
end
