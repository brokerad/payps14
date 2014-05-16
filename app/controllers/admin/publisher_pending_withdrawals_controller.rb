class Admin::PublisherPendingWithdrawalsController < Admin::ApplicationController
  def index
    @publishers = BillingService.new.pending_withdrawal_publishers
  end

  def show
    @publisher = Publisher.find(params[:id])
    @entries = BillingService.new.publisher_withdrawals_account(@publisher).entries
  end
  
  def transactions
    @publisher = Publisher.find(params[:id])
    @account =  BillingService.new.publisher_checking_account(@publisher)
  end
end
