class CouponRefactory < ActiveRecord::Migration
  def self.up
    add_column :coupons, :tracking_url_id, :integer
  end

  def self.down
    remove_column :coupons, :tracking_url_id      
  end
end
