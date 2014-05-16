require 'spec_helper'

describe BillingService do
  it "should create advertisers account" do
    create_account_plan
    advertiser = Factory(:advertiser)
    @advertisers_receivables_parent.child(advertiser.id).should be_nil
    service = BillingService.new
    service.create_advertiser_accounts(advertiser)
    @advertisers_receivables_parent.reload
    @advertisers_receivables_parent.child(advertiser.id).should_not be_nil
  end

  it "should register an advertiser pending transaction with discount" do
    create_account_plan
    advertiser = Factory(:advertiser)
    service = BillingService.new
    service.create_advertiser_accounts(advertiser)
    @advertisers_receivables_parent.reload
    package = Factory(:prepaid_package, :price => 10000, :discount => 20, :budget => 12000)
    service.buy_package(advertiser, package)
    advertiser_receivables = @advertisers_receivables_parent.child(advertiser.id)

    advertiser_receivables.balance.should eq package.price * -1
    @advertisers_provision.balance.should eq package.price
    @package_discount_provision.balance.should eq package.nominal_discount
    @advertisers_packages_discounts.balance.should eq package.nominal_discount * -1
  end

  it "should confirm an advertiser pending transaction without discount" do
    create_account_plan
    advertiser = Factory(:advertiser)
    service = BillingService.new
    service.create_advertiser_accounts(advertiser)
    @advertisers_receivables_parent.reload
    package = Factory(:prepaid_package, :price => 10000, :discount => 0, :budget => 10000)
    service.buy_package(advertiser, package)
    advertiser_receivables = @advertisers_receivables_parent.child(advertiser.id)

    pending_transaction = advertiser_receivables.entries.first.transaction
    service.confirm_advertiser_payment(pending_transaction)

    advertiser_receivables.balance.should eq 0
    @advertisers_provision.balance.should eq 0
    @package_discount_provision.balance.should eq 0
    @checking_account.balance.should eq package.price * -1
    @advertisers_checking_account_parent.child(advertiser.id).balance.should eq 10000
    @advertisers_packages_discounts.balance.should eq 0
  end

  it "should not change entry" do
    create_account_plan
    advertiser = Factory(:advertiser)
    service = BillingService.new
    service.create_advertiser_accounts(advertiser)
    @advertisers_receivables_parent.reload
    package = Factory(:prepaid_package, :price => 10000, :discount => 20, :budget => 12000)
    service.buy_package(advertiser, package)
    advertiser_receivables = @advertisers_receivables_parent.child(advertiser.id)

    Entry.find_by_account_id(advertiser_receivables.id).should_not be_nil
    service.advertiser_all_payments
    Entry.find_by_account_id(advertiser_receivables.id).should_not be_nil
  end
  
end
