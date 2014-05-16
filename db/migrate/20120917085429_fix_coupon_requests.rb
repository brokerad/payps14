class FixCouponRequests < ActiveRecord::Migration
  # Publisher 16537 aka "Rosario Eulogio" requested many times coupon nr 2
  def self.up
    Transaction.delete_all("id IN(86,87,88,89,90,98,91,92,93,94,95,96,787)")
    Entry.delete_all("transaction_id IN(86,87,88,89,90,98,91,92,93,94,95,96,787)")
  end

  def self.down
  end
end
