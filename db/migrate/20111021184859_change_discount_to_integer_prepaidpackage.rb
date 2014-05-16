class ChangeDiscountToIntegerPrepaidpackage < ActiveRecord::Migration
  def self.up
    change_column :prepaid_packages, :discount, :integer
  end

  def self.down
    change_column :prepaid_packages, :discount, :float
  end
end
