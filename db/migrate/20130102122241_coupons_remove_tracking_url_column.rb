class CouponsRemoveTrackingUrlColumn < ActiveRecord::Migration
  def self.up
    remove_column :coupons, :tracking_url_id
  end

  def self.down
    add_column :coupons, :tracking_url_id, :integer
  end
end
