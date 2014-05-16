class Admin::ConfirmPublisherPendingWithdrawalController < Admin::ApplicationController
  def index
    BillingService.new.confirm_withdrawal Transaction.find(params[:transaction_id])
    redirect_to admin_publisher_pending_withdrawal_path(Publisher.find(params[:publisher_id])), :action => :show
  end
end
