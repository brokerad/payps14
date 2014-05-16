class PublishersTableAddMarketIdColumn < ActiveRecord::Migration
  def self.up
    add_column :publishers, :market_id, :integer
  end

  def self.down
    remove_column :publishers, :market_id
  end
end
