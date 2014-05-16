class AddPartnerCouponsDiscountAccount < ActiveRecord::Migration
  def self.up
    root = Account.where(:name => BillingService::ROOT, :parent_id => nil).first
    expenses = root.child BillingService::EXPENSES
    discounts = expenses.child BillingService::DISCOUNTS
    if discounts.child(BillingService::PARTNER_COUPONS_DISCOUNTS).nil?
      discounts.children.create! :name => BillingService::PARTNER_COUPONS_DISCOUNTS,
                                 :nature => Account::DEBIT_NATURE
    end
  end
end
