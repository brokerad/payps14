require "base62"

class TrackingCode < ActiveRecord::Base
  belongs_to :post

  validates_presence_of :target_url

  has_many :tracking_requests

  def url
    "http://#{APP_DOMAIN}/t/#{self.code}"
  end

  def code
    self.id.to_i.base62_encode
  end

  def image?
    self.post.ad.picture_link == self.target_url
  end

  def self.find_by_code code
    find code.base62_decode
  end

  def count
    self.tracking_requests.count
  end
end
