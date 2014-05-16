class PartnerConditionsRenameToRevenueShares < ActiveRecord::Migration
  def self.up
    rename_table :partner_conditions, :revenue_shares
  end
  def self.down
    rename_table :revenue_shares, :partner_conditions
  end
end
