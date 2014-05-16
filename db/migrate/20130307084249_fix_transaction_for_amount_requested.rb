# SELECT * 
# FROM transactions
# WHERE description LIKE 'Publisher 14591 %' 
#
# SELECT *
# FROM entries
# WHERE entries.transaction_id = 974

class FixTransactionForAmountRequested < ActiveRecord::Migration
  def self.up
    list = [{ :publisher_id                         => 4111,
              :request_transaction                  => 726, 
              :request_transaction_positive_entry   => 15039, 
              :request_transaction_negative_entry   => 15038, 
              :received_transaction                 => 898, 
              :received_transaction_positive_entry  => 19007, 
              :received_transaction_negative_entry  => 19006,               
              :amount                               => 25.66},
            { :publisher_id                         => 14591,
              :request_transaction                  => 675, 
              :request_transaction_positive_entry   => 14306, 
              :request_transaction_negative_entry   => 14305, 
              :received_transaction                 => 974, 
              :received_transaction_positive_entry  => 18997, 
              :received_transaction_negative_entry  => 18996,               
              :amount                               => 7.20},
            { :publisher_id                         => 4933,
              :request_transaction                  => 731, 
              :request_transaction_positive_entry   => 15049, 
              :request_transaction_negative_entry   => 15048, 
              :received_transaction                 => 980, 
              :received_transaction_positive_entry  => 19009, 
              :received_transaction_negative_entry  => 19008,               
              :amount                               => 1.95},
            { :publisher_id                         => 2543,
              :request_transaction                  => 664, 
              :request_transaction_positive_entry   => 14284, 
              :request_transaction_negative_entry   => 14283, 
              :received_transaction                 => 970, 
              :received_transaction_positive_entry  => 18989, 
              :received_transaction_negative_entry  => 18988,               
              :amount                               => 11.82}
           ]

    list.each do |l|
      entry = Entry.find(l[:request_transaction_negative_entry])
      entry.amount = (l[:amount] * -1)
      entry.save!

      entry = Entry.find(l[:request_transaction_positive_entry])
      entry.amount = l[:amount]
      entry.save!

      entry = Entry.find(l[:received_transaction_negative_entry])
      entry.amount = (l[:amount] * -1)
      entry.save!

      entry = Entry.find(l[:received_transaction_positive_entry])
      entry.amount = l[:amount]
      entry.save!

      transaction = Transaction.find(l[:request_transaction])
      transaction.description = "Publisher #{l[:publisher_id]} requested a #{l[:amount]} withdrawal"
      transaction.save(false) # false stay for 'skip validation'
      
      transaction = Transaction.find(l[:received_transaction])
      transaction.description = "Publisher #{l[:publisher_id]} received #{l[:amount]}"
      transaction.save(false)
    end
  end
  
  def self.down
  end
end
