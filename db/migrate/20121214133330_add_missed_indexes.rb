class AddMissedIndexes < ActiveRecord::Migration
  def self.up
    add_index :publishers, :tracking_url_id
    add_index :tracking_urls, :partner_id
  end

  def self.down
    remove_index :publishers, :tracking_url_id
    remove_index :tracking_urls, :partner_id
  end
end
