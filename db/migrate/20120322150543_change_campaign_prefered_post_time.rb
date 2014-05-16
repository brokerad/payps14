class ChangeCampaignPreferedPostTime < ActiveRecord::Migration
  def self.up
    drop_table :campaign_prefered_post_times

    create_table :campaign_prefered_post_times do |t|
      t.integer :post_time_id, :null => false
      t.integer :campaign_id, :null => false
    end
  end

  def self.down
    drop_table :campaign_prefered_post_times

    create_table :campaign_prefered_post_times do |t|
      t.references :campaign, :null => false
      t.integer :post_time, :null => false
    end
  end
end
