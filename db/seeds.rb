def find_or_create_account(name, parent, nature)
  account = Account.find_by_name(name)
  return account if account
  
  account = Account.new(:name => name, :parent => parent, :nature => nature)
  account.save!
  account
end

liabilities = Account.find_by_name(BillingService::LIABILITIES)
  find_or_create_account(BillingService::REVENUE_SHARE_CHECKING_ACCOUNTS, liabilities, Account::CREDIT_NATURE)
  find_or_create_account(BillingService::REVENUE_SHARE_WITHDRAWALS_ACCOUNTS, liabilities, Account::CREDIT_NATURE)

av = AdminVariable.find_or_initialize_by_key('partner_minumum_amount_for_pay'); av.value = '0.5'; av.save!

puts 'clearing cache'
Rails.cache.clear
puts 'done!'