require "koala"
require "base62"

class Post < ActiveRecord::Base

  MANUAL = "MANUAL"
  AUTOPUBLISHING = "AUTOPUBLISHING"

  belongs_to :ad
  belongs_to :place

	has_many :tracking_requests
	has_many :impressions 

  validates_associated :ad
  validates_associated :place

  validates :source, :inclusion => {:in => [MANUAL, AUTOPUBLISHING]},
                     :presence => true

	validates_length_of :target_url, :maximum => 1024
 
  after_create :create_tracking_code

  def clicks
    TrackingRequest.count_by_sql "
      SELECT COUNT(*)
      FROM tracking_requests
        JOIN posts ON (tracking_requests.post_id = posts.id)
      WHERE posts.id = #{self.id}
        AND tracking_requests.status = '#{TrackingRequest::PAYABLE}'"
  end

  def url
    "http://#{APP_DOMAIN}/t/#{self.tracking_code}"
  end
  
  def image_url
  	"http://#{APP_DOMAIN}/i/#{self.tracking_code}"
  end
  
  def update_data
    graph = Koala::Facebook::GraphAPI.new(place.access_token)
    post_data = graph.get_object(self.reference_id)
    self.comments = 0
    self.likes = 0
    self.link = ""
    if post_data
      if post_data["comments"] and post_data["comments"]["count"]
        self.comments = post_data["comments"]["count"].to_i
      end
      if post_data["likes"] and post_data["likes"]["count"]
        self.likes = post_data["likes"]["count"].to_i
      end
      if post_data["actions"] and post_data["actions"][0] and post_data["actions"][0]["link"]
        self.link = post_data["actions"][0]["link"]
      end
    end
    save
  end

  def publisher
    return self.place.publisher_facebook.publisher
  end

  private

  def create_tracking_code  
		# TODO 26.4.2012 (Giacomo -> Jonas) Here the tracking_code is created, we need to solve collisions
    self.update_attributes(:tracking_code => self.id.to_i.base62_encode)
  end

  def self.update_posts_count_all
    posts_to_update = Post.where("updated_at <= ?", Time.now.utc - 1.day).
     order("updated_at ASC")
    posts_to_update.each do | post  |
      post.update_data
    end
  end
end
