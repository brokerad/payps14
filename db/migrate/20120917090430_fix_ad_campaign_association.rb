class FixAdCampaignAssociation < ActiveRecord::Migration
  def self.up
    ads = Ad.where("id IN(166,190,191,193,194,198,351)")
    ads.each do |ad|
      ad.campaign_id = 88
      ad.save
    end
  end

  def self.down
  end
end
