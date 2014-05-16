class CampaignsTableAddMarketIdColumn < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :market_id, :integer
  end

  def self.down
    remove_column :campaigns, :market_id
  end
end
