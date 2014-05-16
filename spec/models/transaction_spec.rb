require 'spec_helper'

describe Transaction do
  it "Should create a simple transaction with 2 entries" do
    root = Factory(:root_account)
    assets = Factory(:account,
                     :name => "Assets",
                     :nature => Account::DEBIT_NATURE,
                     :parent => root)
    liabilities = Factory(:account,
                          :name => "Liabilities",
                          :nature => Account::CREDIT_NATURE,
                          :parent => root)
    root.children.size.should eq 2

    asset_entry = Entry.new(:amount => BigDecimal.new("10"), :account => assets)
    liability_entry = Entry.new(:amount => BigDecimal.new("-10"), :account => liabilities)

    transaction = Transaction.new(:description => "Simple transaction",
                                  :entries => [asset_entry, liability_entry])
    transaction.save.should be_true
  end

  it "Should not allow unbalanced transactions" do
    root = Factory(:root_account)
    assets = Factory(:account,
                     :name => "Assets",
                     :nature => Account::DEBIT_NATURE,
                     :parent => root)
    liabilities = Factory(:account,
                          :name => "Liabilities",
                          :nature => Account::CREDIT_NATURE,
                          :parent => root)
    root.children.size.should eq 2

    asset_entry = Entry.new(:amount => BigDecimal.new("10"), :account => assets)
    liability_entry = Entry.new(:amount => BigDecimal.new("-15"), :account => liabilities)

    transaction = Transaction.new(:description => "Simple transaction",
                                  :entries => [asset_entry, liability_entry])
    transaction.save.should be_false
    transaction.errors.should have_key(:unbalanced_transaction_error)
  end

  it "should update account balances" do
    root = Factory(:root_account)
    assets = Factory(:account,
                     :name => "Assets",
                     :nature => Account::DEBIT_NATURE,
                     :parent => root)
    liabilities = Factory(:account,
                          :name => "Liabilities",
                          :nature => Account::CREDIT_NATURE,
                          :parent => root)
    root.children.size.should eq 2

    asset_entry = Entry.new(:amount => BigDecimal.new("10"), :account => assets)
    liability_entry = Entry.new(:amount => BigDecimal.new("-10"), :account => liabilities)

    transaction = Transaction.new(:description => "Simple transaction",
                                  :entries => [asset_entry, liability_entry])
    transaction.save.should be_true
    assets.balance.should eq BigDecimal.new("10")
    liabilities.balance.should eq BigDecimal.new("-10")
  end
end
