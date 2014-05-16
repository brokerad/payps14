class CampaignPreferedPostTimesAddMissedIndexes < ActiveRecord::Migration
  def self.up
    add_index :campaign_prefered_post_times, :post_time_id
    add_index :campaign_prefered_post_times, :campaign_id
  end

  def self.down
    remove_index :campaign_prefered_post_times, :post_time_id
    remove_index :campaign_prefered_post_times, :campaign_id
  end
end
