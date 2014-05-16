class Advertiser < ActiveRecord::Base
  attr_accessor :new_password

  validates_presence_of :company_name, :address, :city, :country, :zip_code, :phone, :site
  validates_presence_of :user

  validates_associated :user

  validates_format_of :site, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix

  belongs_to :user, :dependent => :destroy

  has_many :campaigns
  has_many :ads, :through => :campaigns

  accepts_nested_attributes_for :user

  before_validation :set_user_role

  def has_history
    campaigns.count > 0
  end

  private

  def set_user_role
    self.user.role = User::ADVERTISER
  end

  def self.all_active
    joins(:user).merge(User.active)
  end
end
