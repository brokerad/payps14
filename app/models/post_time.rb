class PostTime < ActiveRecord::Base
  has_many :campaign_prefered_post_times
  has_many :campaigns, :through => :campaign_prefered_post_times
end
