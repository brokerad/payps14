module PaypersocialHelper
  
  def today; Time.now.utc; end
  def tomorrow; Time.now.utc + 1.days; end
  def yesterday; Time.now.utc - 1.days; end
  def day(add); Time.now.utc + add.days; end
  
  def check_presence(factory_name, field)
    fo = Factory.build(factory_name, field => nil)
    fo.valid?.should be_false
    fo.errors[field][0].should eq "can't be blank"
  end

  def check_uniqueness(factory_name, field)
    fo = Factory.build(factory_name, field => Factory(factory_name).send(field))
    fo.valid?.should be_false
    fo.errors[field][0].should eq 'has already been taken'
  end

  def check_to_be_positive_number(factory_name, field)
    pt = Factory.build(factory_name, field => -1)
    pt.valid?.should be_false
    pt.errors[field][0].should eq "must be greater than or equal to 0"
  end

  def check_to_be_float(factory_name, field)
    pt = Factory(factory_name, field => 10.12)
    pt.valid?.should be_true
    object = pt.class.name.constantize
    object.find(pt).send(field).should eq 10.12
  end

  def check_to_be_integer(factory_name, field)
    pt = Factory.build(factory_name, field => 10.5)
    pt.valid?.should be_false
    pt.errors[field][0].should eq "must be an integer"
  end

  def check_to_be_numerical(factory_name, field)
    pt = Factory.build(factory_name, field => 'number')
    pt.valid?.should be_false
    pt.errors[field][0].should eq "is not a number"
  end
  
  def create_billing_system
    root = create_account BillingService::ROOT, nil, Account::ROOT_NATURE
      assets = create_account BillingService::ASSETS, root, Account::DEBIT_NATURE
        banks = create_account BillingService::BANKS, assets, Account::DEBIT_NATURE
          checking_account = create_account BillingService::CHECKING_ACCOUNT, banks, Account::DEBIT_NATURE
        
        receivables = create_account BillingService::RECEIVABLES, assets, Account::DEBIT_NATURE
          advertisers_receivables = create_account BillingService::ADVERTISERS_RECEIVABLES, receivables, Account::DEBIT_NATURE
        
        provisions = create_account BillingService::PROVISIONS, assets, Account::CREDIT_NATURE
          advertisers_provision = create_account BillingService::ADVERTISERS_PROVISION, provisions, Account::CREDIT_NATURE
          package_discount_provision = create_account BillingService::PACKAGE_DISCOUNT_PROVISION, provisions, Account::CREDIT_NATURE
    
    liabilities = create_account BillingService::LIABILITIES, root, Account::CREDIT_NATURE
      advertisers_liabilities = create_account BillingService::ADVERTISERS_CHECKING_ACCOUNTS, liabilities, Account::CREDIT_NATURE
      campaigns_checking_account_parent = create_account BillingService::CAMPAIGNS_CHECKING_ACCOUNTS, liabilities, Account::CREDIT_NATURE
      publishers_checking_account_parent = create_account BillingService::PUBLISHERS_CHECKING_ACCOUNTS, liabilities, Account::CREDIT_NATURE
      publishers_withdrawals = create_account BillingService::PUBLISHERS_WITHDRAWALS, liabilities, Account::CREDIT_NATURE

      revenue_shares_checking_account_parent = create_account BillingService::REVENUE_SHARE_CHECKING_ACCOUNTS, liabilities, Account::CREDIT_NATURE
      revenue_shares_withdrawals_account_parent = create_account BillingService::REVENUE_SHARE_WITHDRAWALS_ACCOUNTS, liabilities, Account::CREDIT_NATURE
      
    expenses = create_account BillingService::EXPENSES, root, Account::DEBIT_NATURE
      discounts = create_account BillingService::DISCOUNTS, expenses, Account::DEBIT_NATURE
        advertisers_packages_discounts = create_account BillingService::ADVERTISERS_PACKAGES_DISCOUNTS, discounts, Account::DEBIT_NATURE
    
    income = create_account BillingService::INCOME, root, Account::CREDIT_NATURE
      publishers_income_parent = create_account BillingService::PUBLISHERS_INCOME, income, Account::CREDIT_NATURE
  end
  
  def create_account name, parent, nature
    account = Account.find_by_name(name)
    return account if account
    
    account = Account.new(:name => name, :parent => parent, :nature => nature)
    account.save!
    account
  end

  def read_billing_system
    root = Account.where(:name => BillingService::ROOT, :parent_id => nil).first
    assets = root.child BillingService::ASSETS
    banks = assets.child BillingService::BANKS
    @checking_account = banks.child BillingService::CHECKING_ACCOUNT
    receivables = assets.child BillingService::RECEIVABLES
    
    @advertisers_receivables_parent = receivables.child BillingService::ADVERTISERS_RECEIVABLES
    @provisions_parent = assets.child BillingService::PROVISIONS
    
    @advertisers_provision = @provisions_parent.child BillingService::ADVERTISERS_PROVISION
    @package_discount_provision = @provisions_parent.child BillingService::PACKAGE_DISCOUNT_PROVISION
    liabilities = root.child BillingService::LIABILITIES

    @advertisers_checking_account_parent = liabilities.child BillingService::ADVERTISERS_CHECKING_ACCOUNTS
    @campaigns_checking_account_parent = liabilities.child BillingService::CAMPAIGNS_CHECKING_ACCOUNTS
    @publishers_checking_account_parent = liabilities.child BillingService::PUBLISHERS_CHECKING_ACCOUNTS
    @publishers_withdrawals_parent = liabilities.child BillingService::PUBLISHERS_WITHDRAWALS
    
    @revenue_shares_checking_account_parent = liabilities.child BillingService::REVENUE_SHARE_CHECKING_ACCOUNTS
    @revenue_shares_withdrawals_account_parent = liabilities.child BillingService::REVENUE_SHARE_WITHDRAWALS_ACCOUNTS
    
    expenses = root.child BillingService::EXPENSES
    discounts = expenses.child BillingService::DISCOUNTS
    @packages_discounts_expenses = discounts.child BillingService::ADVERTISERS_PACKAGES_DISCOUNTS
    @partner_coupons_discount_expenses = discounts.child BillingService::PARTNER_COUPONS_DISCOUNTS
    
    income = root.child BillingService::INCOME
    @publishers_income_parent = income.child BillingService::PUBLISHERS_INCOME
  end

end