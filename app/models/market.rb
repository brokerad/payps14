class Market < ActiveRecord::Base
  
  has_many :campaigns
  has_many :publishers
  
  validates :name, :presence => true
  validates :iso_code, :presence => true

  default_scope :order => "name ASC"
end
