class RevenueSharesTableAddTrackingUrlId < ActiveRecord::Migration
  def self.up
    add_column :revenue_shares, :tracking_url_id, :integer
  end

  def self.down
    remove_column :revenue_shares, :tracking_url_id
  end
end
