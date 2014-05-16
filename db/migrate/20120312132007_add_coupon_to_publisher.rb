class AddCouponToPublisher < ActiveRecord::Migration
  def self.up
    add_column :publishers, :coupon_id, :integer
  end

  def self.down
    remove_column :publishers, :coupon_id
  end
end
