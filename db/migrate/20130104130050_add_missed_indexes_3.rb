class AddMissedIndexes3 < ActiveRecord::Migration
  def self.up
    add_index :coupons_tracking_urls, :coupon_id
    add_index :coupons_tracking_urls, :tracking_url_id
    add_index :revenue_shares, :tracking_url_id
    add_index :revenue_shares, :partner_id
  end

  def self.down
    remove_index :coupons_tracking_urls, :coupon_id
    remove_index :coupons_tracking_urls, :tracking_url_id
    remove_index :revenue_shares, :tracking_url_id
    remove_index :revenue_shares, :partner_id
  end
end
