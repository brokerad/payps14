class AddCampaignsIndex < ActiveRecord::Migration
  def self.up
    add_index :campaigns, :advertiser_id
  end

  def self.down
    remove_index :campaigns, :advertiser_id
  end
end
