class CouponsRenameFromAndToColumns < ActiveRecord::Migration
  def self.up
    rename_column(:coupons, :from_date, :start_date)
    rename_column(:coupons, :to_date, :end_date)
  end

  def self.down
    rename_column(:coupons, :start_date, :from_date)
    rename_column(:coupons, :end_date, :to_date)
  end
end
