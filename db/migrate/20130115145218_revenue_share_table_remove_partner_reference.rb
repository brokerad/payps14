class RevenueShareTableRemovePartnerReference < ActiveRecord::Migration
  def self.up
    remove_column :revenue_shares, :partner_id
  end

  def self.down
    add_column :revenue_shares, :partner_id, :integer
  end
end
