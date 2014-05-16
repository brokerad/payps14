class RemoveCampaignFromPost < ActiveRecord::Migration
  def self.up
    remove_column :posts, :campaign_id
  end

  def self.down
    add_column :posts, :campaign_id, :integer
  end
end
