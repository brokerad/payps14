class Partner < ActiveRecord::Base

  belongs_to :user, :autosave => true

  has_many :tracking_urls, :dependent => :destroy
  has_many :coupons, :dependent => :destroy
  has_many :revenue_shares, :through => :tracking_urls

  has_many :publishers, :through => :tracking_urls
  belongs_to :admin, :class_name => "User", :foreign_key => "admin_id", :conditions => ['role = ?', User::ADMIN]

  validates_presence_of :name, :address, :zip, :city, :country
  validates :name, :uniqueness => true
  validates_inclusion_of :admin_id, :in => [nil, User.where(:role => User::ADMIN).map {|a| a.id }].flatten

  validates_presence_of :user
  accepts_nested_attributes_for :user

  default_scope :order => 'created_at desc'

# TODO: (Giacomo) Verify this method
#   def trackback_url publisher
#     self.lead_url.gsub("{PUBLISHER_ID}", publisher.id.to_s).gsub("{PUBLISHER_EMAIL}", publisher.email)
#   end

  has_many :publishers_incomplete, :class_name => 'Publisher', :conditions => ['accepted_term_id is null']
  has_many :publishers_complete, :class_name => 'Publisher', :conditions => ['accepted_term_id is not null']

  def trackback_url publisher
    self.lead_url.
      gsub("{PUBLISHER_ID}", publisher.id.to_s).
      gsub("{PUBLISHER_EMAIL}", publisher.email).
      gsub("{VALIDATION}", publisher.friends > 0 ? '1' : '0' )
  end

  def revenue_share_matured
    revenue_shares.inject(0) { |sum, pc| sum + pc.matured }
  end

  def register!
    user.set_new_email_token
    user.enabled = false
    user.role = User::PARTNER
    save
  end

end
