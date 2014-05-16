class AddTrackingIndexes < ActiveRecord::Migration
  def self.up
    add_index :tracking_requests, :session_id
    add_index :tracking_requests, [:created_at, :ip]
    add_index :tracking_requests, :post_id
    add_index :posts, :ad_id
  end

  def self.down
    remove_index :tracking_requests, :session_id
    remove_index :tracking_requests, [:created_at, :ip]
    remove_index :tracking_requests, :post_id
    remove_index :posts, :ad_id
  end
end
