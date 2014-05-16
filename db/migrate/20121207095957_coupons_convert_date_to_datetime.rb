class CouponsConvertDateToDatetime < ActiveRecord::Migration
  def self.up
    change_column(:coupons, :from_date, :datetime)
    change_column(:coupons, :to_date, :datetime)
  end

  def self.down
    change_column(:coupons, :from_date, :date)
    change_column(:coupons, :to_date, :date)
  end
end
