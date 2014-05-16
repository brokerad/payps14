class FixMultiplePaymentRequests < ActiveRecord::Migration
  def self.up
    # Publisher 27185
    Entry.find(25042).delete
    Entry.find(25043).delete
    Transaction.find(1502).delete
    
    # Publisher 27124
    Entry.find(23658).delete
    Entry.find(23657).delete
    Transaction.find(1199).delete

    # Publisher 2543
    Entry.find(25036).delete
    Entry.find(25037).delete
    Transaction.find(1499).delete
  end

  def self.down
  end
end
