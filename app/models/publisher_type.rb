class PublisherType < ActiveRecord::Base
  BASIC = "basic"

  validates :name, :payment_delay, :commission, :minimal_payment, :presence => true
  validates :name, :uniqueness => true

  validates :payment_delay, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :commission, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100 }
  validates :minimal_payment, :numericality => { :greater_than_or_equal_to => 0 }

  has_many :publishers
  has_and_belongs_to_many :ads

  before_destroy :can_be_destroyed

  after_save :update_is_default

  def self.get_default
    default = PublisherType.where(:is_default => true).first
    default = PublisherType.where(:name => BASIC).first unless default
    default = PublisherType.first unless default
    default
  end

  private

  def can_be_destroyed
    errors[:base] << 'has attached publishers' unless can_destroy = publishers.count == 0
    can_destroy
  end

  def update_is_default
    PublisherType.where('id not in (?)', id).update_all(:is_default => false) if is_default
  end

end
