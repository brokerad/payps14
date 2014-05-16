class Partner::BillingsController < Partner::ApplicationController
  
  before_filter :init_variables
  helper_method :can_request_amount?
  
  def revenue_share; end
  
  def request_payment    
    if can_request_amount?
      BillingService.new.partner_request_withdrawal(@partner)
      flash[:success] = 'Request was registered with success'
    else
      flash[:error] = 'Not enough amount to complete request'
    end
    redirect_to partner_revenue_share_path
  end
  
  protected
  
  def can_request_amount?
    @matured_amount >= @min_amount_for_pay
  end
  
  private
  
  def init_variables
    @partner = current_partner
    @matured_amount = @partner.revenue_share_matured
    @min_amount_for_pay = AdminVariable.partner_minumum_amount_for_pay
    
    @requested_transactions_active = Transaction.select('transactions.id, accounts.name, transactions.description, sum(entries.amount), transactions.created_at').
      joins(:entries => :account).merge(Entry.debited).merge(Entry.not_reconciled_entries).
      where('accounts.parent_id' => BillingService.new.revenue_shares_checking_account_parent).
      where('accounts.name' => @partner.revenue_shares.map {|rs| rs.id.to_s}).
      group('transactions.id, accounts.name')
    @requested_amount = @requested_transactions_active.inject(0) { |sum, p| sum + p['sum'].to_f.abs }

    @requested_transactions_done = Transaction.select('transactions.id, accounts.name, transactions.description, sum(entries.amount), transactions.created_at').
      joins(:entries => :account).merge(Entry.debited).merge(Entry.reconciled_entries).
      where('accounts.parent_id' => BillingService.new.revenue_shares_checking_account_parent).
      where('accounts.name' => @partner.revenue_shares.map {|rs| rs.id.to_s}).
      group('transactions.id, accounts.name')

    @payed_transactions = Transaction.select('transactions.id, accounts.name, transactions.description, sum(entries.amount), transactions.created_at').
      joins(:entries => :account).merge(Entry.debited).merge(Entry.reconciled_entries).
      where('accounts.parent_id' => BillingService.new.revenue_shares_withdrawals_account_parent).
      where('accounts.name' => @partner.revenue_shares.map {|rs| rs.id.to_s}).
      group('transactions.id, accounts.name')
    @payed_amount = @payed_transactions.inject(0) { |sum, p| sum + p['sum'].to_f.abs }
    
    
    # @grouped_withd_trans_reqested_done = Transaction.select('transactions.id, accounts.name, transactions.description, sum(entries.amount), transactions.created_at').
      # joins(:entries => :account).merge(Entry.debited).merge(Entry.reconciled_entries).
      # where('accounts.parent_id' => BillingService.new.revenue_shares_checking_account_parent).
      # group('transactions.id, accounts.name')
# 
    # @grouped_withd_trans_reqested_active = Transaction.select('transactions.id, accounts.name, transactions.description, sum(entries.amount), transactions.created_at').
      # joins(:entries => :account).merge(Entry.debited).merge(Entry.not_reconciled_entries).
      # where('accounts.parent_id' => BillingService.new.revenue_shares_checking_account_parent).
      # group('transactions.id, accounts.name')
#       
    # @grouped_withd_trans_payed = Transaction.select('transactions.id, accounts.name, transactions.description, sum(entries.amount), transactions.created_at').
      # joins(:entries => :account).merge(Entry.debited).merge(Entry.reconciled_entries).
      # where('accounts.parent_id' => BillingService.new.revenue_shares_withdrawals_account_parent).
      # group('transactions.id, accounts.name')
  end

end
