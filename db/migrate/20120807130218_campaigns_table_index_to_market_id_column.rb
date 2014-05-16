class CampaignsTableIndexToMarketIdColumn < ActiveRecord::Migration
  def self.up
    add_index :campaigns, :market_id
  end

  def self.down
    remove_index :campaigns, :market_id
  end
end
