require 'spec_helper'

describe Entry do
  it "should inverse an entry" do
    amount = BigDecimal.new("5")
    account = Factory(:root_account)
    entry = Entry.new(:amount => amount, :account => account, :reconciled => false)
    inverse_entry = entry.inverse
    inverse_entry.amount.should eq amount * -1
    inverse_entry.account.should eq account
    inverse_entry.reconciled.should be_true
  end
end
