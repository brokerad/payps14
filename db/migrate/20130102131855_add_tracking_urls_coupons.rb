class AddTrackingUrlsCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupons_tracking_urls, :id => false do |t|
      t.integer :tracking_url_id
      t.integer :coupon_id
    end
  end

  def self.down
    drop_table :coupons_tracking_urls
  end
end
