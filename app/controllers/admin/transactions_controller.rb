class Admin::TransactionsController < Admin::ApplicationController
  def index
    billing_service = BillingService.new
    if params[:filter_advertiser] && !params[:filter_advertiser].empty?
      @entries = billing_service.all_payments_for_advertiser_id(params[:filter_advertiser])
    else
      @entries = billing_service.advertiser_all_payments
    end

    if params[:filter_transaction_type] == "Rejected"
      @entries.reject!{|p| !p.transaction.rejected?}
    elsif params[:filter_transaction_type] == "Requested"
      @entries.reject!{|p| p.reconciled?}
    elsif params[:filter_transaction_type] == "Confirmed"
      @entries.reject!{|p| !p.reconciled?}
    end

    @advertisers = Advertiser.order("id ASC")
  end

  def confirm_transaction
    billing_service = BillingService.new
    begin
      billing_service.confirm_advertiser_payment(Transaction.find(params[:id]))
      redirect_to admin_transactions_path
    rescue Error::EntryReconciled => e
      flash[:error] = e.message
      redirect_to admin_transactions_path
    end
  end

  def reject_transaction
    billing_service = BillingService.new
    billing_service.reject_advertiser_payment(Transaction.find(params[:id]))
    redirect_to admin_transactions_path
  end
end
