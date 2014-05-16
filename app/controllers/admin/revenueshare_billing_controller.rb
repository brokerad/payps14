class Admin::RevenueshareBillingController < Admin::ApplicationController

  def index
    @grouped_withd_trans_reqested_done = Transaction.select('transactions.id, accounts.name, transactions.description, sum(entries.amount), transactions.created_at').
      joins(:entries => :account).merge(Entry.debited).merge(Entry.reconciled_entries).
      where('accounts.parent_id' => BillingService.new.revenue_shares_checking_account_parent).
      group('transactions.id, accounts.name')

    @grouped_withd_trans_reqested_active = Transaction.select('transactions.id, accounts.name, transactions.description, sum(entries.amount), transactions.created_at').
      joins(:entries => :account).merge(Entry.debited).merge(Entry.not_reconciled_entries).
      where('accounts.parent_id' => BillingService.new.revenue_shares_checking_account_parent).
      group('transactions.id, accounts.name')
      
    @grouped_withd_trans_payed = Transaction.select('transactions.id, accounts.name, transactions.description, sum(entries.amount), transactions.created_at').
      joins(:entries => :account).merge(Entry.debited).merge(Entry.reconciled_entries).
      where('accounts.parent_id' => BillingService.new.revenue_shares_withdrawals_account_parent).
      group('transactions.id, accounts.name')
  end
  
  def pay_withdrawal
    BillingService.new.partner_confirm_withdrawal(Transaction.find(params[:id]))
    redirect_to admin_revenueshare_billing_path
  end

end
