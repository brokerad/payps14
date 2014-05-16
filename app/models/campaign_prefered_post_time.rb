class CampaignPreferedPostTime < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :post_time
end
