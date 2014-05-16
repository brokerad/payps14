class ForcePaymentRequests < ActiveRecord::Migration

  BillingService.class_eval do 
    # This method is used to add force payments requests from publishers 
    def force_insert_payment_for_publisher publisher_id, amount, request_date
      checking_account = @publishers_checking_account_parent.child publisher_id
      if checking_account
        entries = [Entry.new(:amount => amount * -1,
                             :account => checking_account,
                             :reconciled => false,
                             :created_at => Time.parse(request_date).getutc,
                             :updated_at => Time.parse(request_date).getutc),
                   Entry.new(:amount => amount,
                             :account => @publishers_withdrawals_parent.child(publisher_id),
                             :created_at => Time.parse(request_date).getutc,
                             :updated_at => Time.parse(request_date).getutc)]
        Transaction.new(:description => "Publisher #{publisher_id} requested a #{amount} withdrawal",
                        :entries => entries).save
        checking_account.unreconciled_entries.each do |entry|
          entry.reconciled = true
          entry.created_at = Time.parse(request_date).getutc
          entry.updated_at = Time.parse(request_date).getutc
          entry.save
        end
      else
      end
    end
  end

  def self.up
    BillingService.new.force_insert_payment_for_publisher 4111, 69.75, "2012-04-30 12:30:00" #2012-07-27 18:29:12 726
    BillingService.new.force_insert_payment_for_publisher 4114, 62.53, "2012-04-30 12:30:00" #2012-07-10 18:02:05 666
    BillingService.new.force_insert_payment_for_publisher 4421, 42.49, "2012-04-30 12:30:00" #2012-07-18 10:20:14 684
    BillingService.new.force_insert_payment_for_publisher 192, 39.98, "2012-04-30 12:30:00" 
    BillingService.new.force_insert_payment_for_publisher 5532, 28.93, "2012-04-30 12:30:00"
    BillingService.new.force_insert_payment_for_publisher 724, 27.30, "2012-04-30 12:30:00" #2012-07-18 10:53:07 685
    BillingService.new.force_insert_payment_for_publisher 8725, 25.32, "2012-04-30 12:30:00"
    BillingService.new.force_insert_payment_for_publisher 14591, 24.60, "2012-04-30 12:30:00" #2012-07-13 01:19:58 675
    BillingService.new.force_insert_payment_for_publisher 4933, 24.48, "2012-04-30 12:30:00" #2012-07-31 16:42:20 731
    BillingService.new.force_insert_payment_for_publisher 4690, 22.45, "2012-04-30 12:30:00" #2012-07-21 07:56:34 707
    BillingService.new.force_insert_payment_for_publisher 8994, 21.79, "2012-04-30 12:30:00" #2012-07-17 23:43:54 680
    BillingService.new.force_insert_payment_for_publisher 2543, 21.01, "2012-04-30 12:30:00" #2012-07-10 14:21:42 664
  end

  def self.down
  end
end
