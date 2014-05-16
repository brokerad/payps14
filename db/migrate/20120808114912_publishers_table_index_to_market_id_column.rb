class PublishersTableIndexToMarketIdColumn < ActiveRecord::Migration
  def self.up
    add_index :publishers, :market_id
  end

  def self.down
    remove_index :publishers, :market_id
  end
end
