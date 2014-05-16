class BillingService
  include Paypersocial
  ROOT = "Slytrade Root Account"
    ASSETS = "Assets"
      BANKS = "Banks"
        CHECKING_ACCOUNT = "Checking Account"
      RECEIVABLES = "Receivables"
        ADVERTISERS_RECEIVABLES =  "Advertiser's Pending Payments"
      PROVISIONS = "Provisions"
        ADVERTISERS_PROVISION = "Advertiser's Payment Provision"
        PACKAGE_DISCOUNT_PROVISION = "Package Discount Provision"
    LIABILITIES = "Liabilities"
      ADVERTISERS_CHECKING_ACCOUNTS = "Advertisers Checking Accounts"
      CAMPAIGNS_CHECKING_ACCOUNTS = "Campaigns Checking Accounts"
      PUBLISHERS_CHECKING_ACCOUNTS = "Publishers Checking Accounts"
      PUBLISHERS_WITHDRAWALS = "Publisher's Withdrawals"
      REVENUE_SHARE_CHECKING_ACCOUNTS = "Revenue Share Checking Accounts"
      REVENUE_SHARE_WITHDRAWALS_ACCOUNTS = "Revenue Share Withdrawals Accounts"
    EXPENSES = "Expenses"
      DISCOUNTS = "Discounts Expenses"
        ADVERTISERS_PACKAGES_DISCOUNTS = "Advertiser's Packages Discounts"
        PARTNER_COUPONS_DISCOUNTS = "Partner Coupon's Discounts"
    INCOME = "Income"
      PUBLISHERS_INCOME = "Publishers Income"

  attr_reader :revenue_shares_withdrawals_account_parent,
              :revenue_shares_checking_account_parent

  def initialize
    root = Rails.cache.fetch("bs_root", :expires_in => 5.minutes) { Account.where(:name => ROOT, :parent_id => nil).first }
    assets = Rails.cache.fetch("bs_assets", :expires_in => 5.minutes) { root.child ASSETS }
    banks = Rails.cache.fetch("bs_banks", :expires_in => 5.minutes) { assets.child BANKS }
    @checking_account = Rails.cache.fetch("bs_checking_account", :expires_in => 5.minutes) { banks.child CHECKING_ACCOUNT }
    receivables = Rails.cache.fetch("bs_receivables", :expires_in => 5.minutes) { assets.child RECEIVABLES }

    @advertisers_receivables_parent = Rails.cache.fetch("bs_arp", :expires_in => 5.minutes) { receivables.child ADVERTISERS_RECEIVABLES }
    @provisions_parent = Rails.cache.fetch("bs_pp", :expires_in => 5.minutes) { assets.child PROVISIONS }

    @advertisers_provision = Rails.cache.fetch("bs_ap", :expires_in => 5.minutes) { @provisions_parent.child ADVERTISERS_PROVISION }
    @package_discount_provision = Rails.cache.fetch("bs_pdp", :expires_in => 5.minutes) { @provisions_parent.child PACKAGE_DISCOUNT_PROVISION }
    liabilities = Rails.cache.fetch("bs_liabilities", :expires_in => 5.minutes) { root.child LIABILITIES }

    @advertisers_checking_account_parent = Rails.cache.fetch("bs_acap", :expires_in => 5.minutes) { liabilities.child ADVERTISERS_CHECKING_ACCOUNTS }
    @campaigns_checking_account_parent = Rails.cache.fetch("bs_ccap", :expires_in => 5.minutes) { liabilities.child CAMPAIGNS_CHECKING_ACCOUNTS }
    @publishers_checking_account_parent = Rails.cache.fetch("bs_pccp", :expires_in => 5.minutes) { liabilities.child PUBLISHERS_CHECKING_ACCOUNTS }
    @publishers_withdrawals_parent = Rails.cache.fetch("bs_pwp", :expires_in => 5.minutes) { liabilities.child PUBLISHERS_WITHDRAWALS }

    @revenue_shares_checking_account_parent = Rails.cache.fetch("bs_rs_cap", :expires_in => 5.minutes) { liabilities.child REVENUE_SHARE_CHECKING_ACCOUNTS }
    @revenue_shares_withdrawals_account_parent = Rails.cache.fetch("bs_rs_wap", :expires_in => 5.minutes) { liabilities.child REVENUE_SHARE_WITHDRAWALS_ACCOUNTS }

    expenses = Rails.cache.fetch("bs_expenses", :expires_in => 5.minutes) { root.child EXPENSES }
    discounts = Rails.cache.fetch("bs_discounts", :expires_in => 5.minutes) { expenses.child DISCOUNTS }
    @packages_discounts_expenses = Rails.cache.fetch("bs_pde", :expires_in => 5.minutes) { discounts.child ADVERTISERS_PACKAGES_DISCOUNTS }
    @partner_coupons_discount_expenses = Rails.cache.fetch("bs_pcde", :expires_in => 5.minutes) { discounts.child PARTNER_COUPONS_DISCOUNTS }

    income = Rails.cache.fetch("bs_income", :expires_in => 5.minutes) { root.child INCOME }
    @publishers_income_parent = Rails.cache.fetch("bs_pip", :expires_in => 5.minutes) { income.child PUBLISHERS_INCOME }
  end

  def advertiser_receivables_account advertiser
    account = @advertisers_receivables_parent.child advertiser.id
    if account.nil?
      create_advertiser_accounts advertiser
      account = advertiser_receivables_account advertiser
    end
    account
  end

  def advertiser_checking_account advertiser
    account = @advertisers_checking_account_parent.child advertiser.id
    if account.nil?
      create_advertiser_accounts advertiser
      account = advertiser_checking_account advertiser
    end
    account
  end

  def campaign_checking_account campaign
    account = @campaigns_checking_account_parent.child campaign.id
    if account.nil?
      create_campaign_accounts campaign
      account = campaign_checking_account campaign
    end
    account
  end

  attr_reader :publishers_checking_account_parent
  def publisher_checking_account publisher
    account = @publishers_checking_account_parent.child publisher.id
    if account.nil?
      create_publisher_accounts publisher
      account = publisher_checking_account publisher
    end
    account
  end

  def publisher_withdrawals_account publisher
    account = @publishers_withdrawals_parent.child publisher.id
    if account.nil?
      create_publisher_accounts publisher
      account = publisher_withdrawals_account publisher
    end
    account
  end

  def publisher_income_account publisher
    account = @publishers_income_parent.child publisher.id
    if account.nil?
      create_publisher_accounts publisher
      account = publisher_income_account publisher
    end
    account
  end

  def revenue_shares_checking_account revenue_share
    account = @revenue_shares_checking_account_parent.child revenue_share.id
    if account.nil?
      create_revenue_share_account revenue_share
      account = revenue_shares_checking_account revenue_share
    end
    account
  end

  def revenue_shares_withdrawal_account revenue_share
    account = @revenue_shares_withdrawals_account_parent.child revenue_share.id
    if account.nil?
      create_revenue_share_account revenue_share
      account = revenue_shares_withdrawal_account revenue_share
    end
    account
  end

  def create_advertiser_accounts advertiser
    @advertisers_receivables_parent.children.create(:name => advertiser.id.to_s, :nature => Account::DEBIT_NATURE)
    @advertisers_checking_account_parent.children.create(:name => advertiser.id.to_s, :nature => Account::CREDIT_NATURE)
  end

  def create_campaign_accounts campaign
    advertiser_account = advertiser_checking_account campaign.advertiser
    if advertiser_account.balance < campaign.budget
      raise I18n.t("campaign.created.no_budget", :budget => campaign.budget, :balance => advertiser_account.balance)
    else
      @campaigns_checking_account_parent.children.create(:name => campaign.id.to_s, :nature => Account::CREDIT_NATURE)
    end
  end

  def create_publisher_accounts publisher
    @publishers_checking_account_parent.children.create(:name => publisher.id.to_s, :nature => Account::CREDIT_NATURE)
    @publishers_income_parent.children.create(:name => publisher.id.to_s, :nature => Account::CREDIT_NATURE)
    @publishers_withdrawals_parent.children.create(:name => publisher.id.to_s, :nature => Account::CREDIT_NATURE)
  end

  def create_revenue_share_account revenue_share
    @revenue_shares_checking_account_parent.children.create(:name => revenue_share.id.to_s, :nature => Account::CREDIT_NATURE)
    @revenue_shares_withdrawals_account_parent.children.create(:name => revenue_share.id.to_s, :nature => Account::CREDIT_NATURE)
  end

  def transfer_to_campaign campaign, budget
    entries = [Entry.new_not_reconciled(budget * -1, advertiser_checking_account(campaign.advertiser)),
               Entry.new_not_reconciled(budget, campaign_checking_account(campaign))]
    Transaction.new(:description => "Transfered resources to campaign #{campaign.id}, amount: #{campaign.budget}",
                    :entries => entries).save
  end

  # positive amount will add money to campaign budget
  # negative amount will extract money from campaign budget
  def modify_amount_to_campaign_budget campaign, amount

    entries = [Entry.new_not_reconciled(amount * -1, advertiser_checking_account(campaign.advertiser)),
              Entry.new_not_reconciled(amount, campaign_checking_account(campaign))]
    Transaction.new(:description =>
      "Updated resources to campaign #{campaign.id} (#{campaign.name}), amount #{amount}",
      :entries => entries).save!
  end

  def buy_package advertiser, package
    entries = [Entry.new_not_reconciled(package.price * -1, advertiser_receivables_account(advertiser)),
               Entry.new_not_reconciled(package.price, @advertisers_provision)]

    if package.discount?
      entries << Entry.new_not_reconciled(package.nominal_discount, @package_discount_provision)
      entries << Entry.new_not_reconciled(package.nominal_discount * -1, @packages_discounts_expenses)
    end

    transaction = Transaction.new(
      :description => "Pending buy credit to advertiser #{advertiser.id}, price #{package.price}, budget #{package.budget}, nominal discount #{package.nominal_discount}",
      :entries => entries)
    transaction.save
  end

  def confirm_advertiser_payment pending_transaction
    advertiser_receivable_entry = pending_transaction.entries.select do |entry|
      entry.account.parent == @advertisers_receivables_parent
    end.first

    if advertiser_receivable_entry.reconciled?
      raise Error::EntryReconciled.new(I18n.t("advertiser.billing.entry_reconciled"))
    end

    entries = [Entry.new_reconciled(advertiser_receivable_entry.amount * -1, advertiser_receivable_entry.account),
               Entry.new_reconciled(advertiser_receivable_entry.amount, @checking_account)]

    nominal_discount = 0
    pending_transaction.entries.select do |entry|
      entry.account.parent == @provisions_parent
    end.each do |provision_entry|
      entries << provision_entry.inverse
      if provision_entry.account == @package_discount_provision
        nominal_discount = provision_entry.amount
      end
    end
    advertiser_id = advertiser_receivable_entry.account.name
    payed = advertiser_receivable_entry.amount * -1 + nominal_discount
    entries << Entry.new_reconciled(payed, @advertisers_checking_account_parent.child(advertiser_id))

    transaction = Transaction.new :description => "Confirmed advertiser payment. Advertiser #{advertiser_id} payed #{payed} with #{nominal_discount} of discount.",
                                  :entries => entries
    transaction.save
    pending_transaction.entries.each do |entry|
      entry.reconciled = true
      entry.save
    end
  end

  def reject_advertiser_payment pending_transaction
    advertiser_receivable_entry = pending_transaction.entries.select do |entry|
      entry.account.parent == @advertisers_receivables_parent
    end.first

    if advertiser_receivable_entry.reconciled?
      raise Error::EntryReconciled.new(I18n.t("advertiser.billing.entry_reconciled"))
    end

    nominal_discount = 0
    pending_transaction.entries.select do |provision_entry|
      if provision_entry.account == @package_discount_provision
        nominal_discount = provision_entry.amount
      end
    end

    advertiser_id = advertiser_receivable_entry.account.name
    payed = advertiser_receivable_entry.amount * -1 + nominal_discount

    pending_transaction.description = "Rejected advertiser request. Advertiser #{advertiser_id} requested #{payed} with #{nominal_discount} of discount."
    pending_transaction.save

    pending_transaction.entries.each do |entry|
      entry.amount = 0.00
      entry.reconciled = true
      entry.save
    end
  end

  def advertiser_pending_payments
    advertiser_all_payments.select { |entry| !entry.reconciled? }
  end

  def advertiser_all_payments
    @advertisers_receivables_parent.all_entries
  end

  def all_payments_for_advertiser_id(advertiser_id)
    filtered_entries = []
    advertiser_all_payments.each do |entry|
      filtered_entries << entry if entry.account.name == advertiser_id
    end
    filtered_entries
  end

  def advertiser_balance advertiser
    advertiser_checking_account(advertiser).balance
  end

  def create_campaign_payment_transaction(campaign, publishers_payable_clicks)
    entries = []
    campaign_total = 0
    campaign_account = campaign_checking_account(campaign)
    
    # In my opinion this should be campaing.budget
    #campaign_balance = campaign_account.balance
    campaign_balance = campaign.budget

    publishers_payable_clicks.each do |publisher|
      publisher_commission = publisher.publisher_type.commission
      payment_advertiser = publisher["payable_clicks_qty"].to_i * campaign.click_value
      campaign_total += payment_advertiser

      commission = calculate_commission(payment_advertiser, publisher_commission)
      partner_amount = publisher_partner_rs(publisher, campaign, publisher_commission)

      entries << Entry.new_not_reconciled(commission - partner_amount, publisher_income_account(publisher))
      entries << Entry.new_not_reconciled(payment_advertiser - commission, publisher_checking_account(publisher))
      #revenue_share
      entries << Entry.new_not_reconciled(partner_amount,
        revenue_shares_checking_account(publisher.revenue_share), "Publisher #{publisher.id}") if partner_amount > 0
    end

    if campaign_total < campaign_balance
      cashback = campaign_balance - campaign_total
      entries << Entry.new_not_reconciled(cashback, advertiser_checking_account(campaign.advertiser))
    end

    entries << Entry.new_not_reconciled(campaign_balance * -1, campaign_account)
    Transaction.new(:description => "Processed campaign #{campaign.id}", :entries => entries).save!
  end

  def request_withdrawal(publisher)
    if publisher.billable?
      pub_checking_account = publisher_checking_account(publisher)
      if pub_checking_account.balance > 0
        entries = [Entry.new_not_reconciled(pub_checking_account.balance * -1, pub_checking_account),
                   Entry.new_not_reconciled(pub_checking_account.balance, @publishers_withdrawals_parent.child(publisher.id))]
        Transaction.new(:description => "Publisher #{publisher.id} requested a #{pub_checking_account.balance} withdrawal",
                        :entries => entries).save
        pub_checking_account.unreconciled_entries.each do |entry|
          reconcile_entry!(entry)
        end
      else
        raise "Publisher doesn't have balance to withdraw. Publisher #{publisher.id} balance: #{pub_checking_account.balance}."
      end
    else
      raise "Publisher #{publisher.id} is not payable."
    end
  end

  def confirm_withdrawal pending_transaction
    publisher_withdrawal_entry = pending_transaction.entries.select do |entry|
      entry.account.parent == @publishers_withdrawals_parent
    end.first
    entries = [Entry.new_reconciled(publisher_withdrawal_entry.amount * -1, publisher_withdrawal_entry.account),
               Entry.new_reconciled(publisher_withdrawal_entry.amount, @checking_account)]
    transaction = Transaction.new(:description => "Publisher #{publisher_withdrawal_entry.account.name} received #{publisher_withdrawal_entry.amount}",
                                  :entries => entries).save
    pending_transaction.entries.each do |entry|
      reconcile_entry!(entry)
    end
  end

  def pending_withdrawal_publishers
    init_publishers(@publishers_withdrawals_parent.children_unreconciled_entries)
  end

  def withdrawal_publishers
    init_publishers(@publishers_withdrawals_parent.children_credit_entries)
  end

  def register_partner_coupon publisher
    if publisher.coupon && publisher.coupon.has_discount?
      entries = [Entry.new_not_reconciled(publisher.coupon.amount * -1, @partner_coupons_discount_expenses),
                 Entry.new_not_reconciled(publisher.coupon.amount, publisher_checking_account(publisher))]
      Transaction.new(:description => "Publisher #{publisher.id} received #{publisher.coupon.amount} for coupon #{publisher.coupon.id}",
                      :entries => entries).save
    end
  end


  #TODO: test me pls!!!
  def partner_request_withdrawal(partner)
    entries = []
    amount_matured = 0

    ActiveRecord::Base.transaction do
      partner.revenue_shares.each do |rs|
        BillingService.new.revenue_shares_checking_account(rs).entries.credited.not_reconciled_entries.each do |entry|
          reconcile_entry!(entry)
          entries << Entry.new_not_reconciled((entry.amount * -1), revenue_shares_checking_account(rs))
          entries << Entry.new_not_reconciled(entry.amount, revenue_shares_withdrawal_account(rs))
        end
      end

      Transaction.create!(
        :description => "Partner #{partner.id} requested withdrawal",
        :entries => entries)
    end
  end

  #TODO: test me pls!!!
  def partner_confirm_withdrawal(transaction)
    ActiveRecord::Base.transaction do
      entries = []
      transaction.entries.not_reconciled_entries.each do |entry|
        reconcile_entry!(entry)
        if entry.account.parent == @revenue_shares_withdrawals_account_parent
          entries << Entry.new_reconciled((entry.amount * -1), entry.account)
          entries << Entry.new_reconciled(entry.amount, @checking_account)
        end
      end

      Transaction.create!(
        :description => "Confimed partner withdrawal transaction #{transaction.id}",
        :entries => entries) unless entries.blank?
    end
  end


  private

  def reconcile_entry!(entry)
    entry.reconciled = true; entry.save!
  end

  def init_publishers(entries)
    entries.collect do |entry|
      publisher = Publisher.find entry.account.name
      publisher.processing_amount_val, publisher.request_payment_date_val = entry.amount, entry.created_at if publisher
      publisher
    end
  end

  def publisher_partner_rs(publisher, campaign, commission_percents)
      partner_eligable_clicks_total_amount = publisher.get_partner_payable_clicks(campaign) * campaign.click_value
      partner_eligable_clicks_commission = ((partner_eligable_clicks_total_amount * commission_percents) / 100).round(2, BigDecimal::ROUND_DOWN)
      partner_eligable_clicks_amount = partner_eligable_clicks_total_amount - partner_eligable_clicks_commission
      partner_amount = ((partner_eligable_clicks_amount * publisher.revenue_share_revenue) / 100).round(2, BigDecimal::ROUND_DOWN)
  end

  def calculate_commission(total, commission)
    (total * commission / 100).round(2, BigDecimal::ROUND_DOWN)
  end
end
