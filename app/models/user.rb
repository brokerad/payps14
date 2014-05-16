require "digest/md5"

class User < ActiveRecord::Base
  acts_as_authentic

  ADMIN = "admin"
  ADVERTISER = "advertiser"
  PUBLISHER = "publisher"
  PARTNER = "partner"
  ROLE_DELIMITER = "|"
  EMAIL_VALIDATION_TOKEN_EXPIRATION_DAYS = 2.days
  PASSWORD_RESET_TOKEN_EXPIRATION_DAYS = 1.days

  validates_presence_of :email
  validates_presence_of :role
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password, :on => :create

  scope :active, where(:enabled => true)
  
  has_one :publisher
  has_one :partner
  has_one :advertiser

  def active?
    self.enabled
  end
  
  # at the moment just publisher & partner should confirm they email
  def confirmed?
    self.role == User::PUBLISHER || self.role == User::PARTNER ? self.is_email_confirmed : true
  end

  def role?(role_name)
    roles.include?(role_name)
  end

  def add_role(role_name)
    roles << role_name
    roles.uniq!
    self.role = roles.join(ROLE_DELIMITER)
  end

  def remove_role(role_name)
    new_roles = Array.new
    new_roles = self.roles
    new_roles.delete(role_name)
    self.role = new_roles.join(ROLE_DELIMITER)
    self.save!
  end

  def add_role!(role_name)
    save if add_role(role_name)
  end

  def roles
    @roles ||= self.role.to_s.split(ROLE_DELIMITER)
  end

  def self.create_from_facebook(fb_publisher)
    user = fb_publisher.publisher ? fb_publisher.publisher.user : User.new
    if(user.persisted?)
      user.add_role!(User::PUBLISHER)
    else
      pass = generate_password_with_key(fb_publisher.email)
      user.password = pass
      user.password_confirmation = pass
      user.enabled = true
      user.email = fb_publisher.email
      user.is_email_confirmed = true
      user.role = User::PUBLISHER
      user.save
    end
    user.mark_account_as_verified unless user.is_email_confirmed
    user
  end

  def set_new_email_token
    self.email_token = SecureRandom::hex(32)
    self.email_token_exp = Time.now.utc + EMAIL_VALIDATION_TOKEN_EXPIRATION_DAYS
  end
  
  def reset_password_token
    self.password_token = SecureRandom::hex(32)
    self.password_token_exp = Time.now.utc + PASSWORD_RESET_TOKEN_EXPIRATION_DAYS
    save
  end
  
  def mark_account_as_verified
    update_attribute(:is_email_confirmed, true)
  end

  def self.is_email_token_valid?(token)
    return nil if token.blank? || token.length != 64
    self.where("email_token = :token AND email_token_exp >= :date", { :token => token, :date => Time.now.utc }).first
  end

  def reset_email_token
    set_new_email_token
    save
  end

  def self.get_user_by_email(email)
    where(:email => email).first
  end
  
  def self.is_password_token_valid?(token)
    return nil if token.blank? || token.length != 64
    self.where("password_token = :token AND password_token_exp >= :date", { :token => token, :date => Time.now.utc }).first
  end

  def invalidate_password_token!
    self.password_token = nil
    self.password_token_exp = Time.now.utc - 1
  end

  def change_password!(password)
    update_attributes(:password => password, :password_confirmation => password)
  end

  def managed_publishers_count
    Publisher.where("admin_id = ?", self.id).count 
  end

  def active_posts_with_payable_clicks_count
    active_posts_with_payable_clicks.count
  end

  def active_posts_count
    active_posts.count.count
  end

  def active_ads_count
    active_ads.count.count
  end

  def active_posts_with_payable_clicks
    TrackingRequest.joins(:post => [:ad, [:place => [:publisher_facebook => [:publisher]]]]).
      where("publishers.admin_id = ?", self.id).
      where("? between ads.start_date and ads.end_date", Time.now.utc).
      where("tracking_requests.status = ?", TrackingRequest::PAYABLE)
  end
  
  def active_posts
    Post.includes(:ad).
      joins(:ad).
      joins(:place => [:publisher_facebook => [:publisher]]).
      where("publishers.admin_id = ?", self.id).
      where("? BETWEEN ads.start_date AND ads.end_date", Time.now.utc).
      group('posts.id')
  end
  
  def active_ads
    Ad.select('COUNT(*) AS count, ads.*').
      joins(:posts => [:place => [:publisher_facebook => [:publisher]]]).
      where("publishers.admin_id = ?", self.id).
      where("? between ads.start_date and ads.end_date", Time.now.utc).
      group('ads.id')
  end
  
  private

  def self.generate_password_with_key(key)
    Digest::MD5.hexdigest(Time.now.utc.to_i.to_s + key.to_s)
  end
end
