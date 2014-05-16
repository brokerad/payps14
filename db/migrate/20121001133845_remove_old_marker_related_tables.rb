class RemoveOldMarkerRelatedTables < ActiveRecord::Migration
  def self.up
    drop_table :publisher_markets
    drop_table :market_campaigns
  end

  def self.down
    # noop
  end
end
