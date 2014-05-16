class Place < ActiveRecord::Base
  
  TYPE_ACCOUNT = "Account"
  TYPE_PAGE = "Page"
  DEFAULT_CLICK_THROUGH = 1
  
  belongs_to :publisher
  belongs_to :publisher_facebook

  has_many :posts

  validates_inclusion_of :place_type, :in => [TYPE_ACCOUNT, TYPE_PAGE]

  def posts_count
    Post.where(:place_id => self.id).count
  end

  def clicks_count
    TrackingRequest.includes(:tracking_code, { :tracking_code => :post }).where("tracking_requests.status = ? AND posts.place_id = ?",TrackingRequest::PAYABLE,self.id).count
  end

  def click_through
    #TODO Change the clicks.to_f to BigDecimal.new
    p = posts_count
    p.zero? ?  DEFAULT_CLICK_THROUGH : clicks.to_f / p
  end

   def places_to_update
    Place.where("updated_at <= ?", Time.now.utc - 1.day).order("updated_at ASC")
  end
end
