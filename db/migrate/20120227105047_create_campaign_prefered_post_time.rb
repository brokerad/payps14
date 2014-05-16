class CreateCampaignPreferedPostTime < ActiveRecord::Migration
  def self.up
    create_table :campaign_prefered_post_times do |t|
      t.references :campaign, :null => false
      t.integer :post_time, :null => false
    end
    Campaign.find_each do |campaign|
      (0..23).each do |post_time|
        CampaignPreferedPostTime.create! :campaign => campaign, :post_time => post_time
      end
    end
  end

  def self.down
    drop_table :campaign_prefered_post_times
  end
end
