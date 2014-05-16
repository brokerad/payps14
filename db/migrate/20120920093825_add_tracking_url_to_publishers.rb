class AddTrackingUrlToPublishers < ActiveRecord::Migration
  def self.up
    add_column :publishers, :tracking_url_id, :integer
  end

  def self.down
    remove_column :publishers, :tracking_url_id
  end
end
