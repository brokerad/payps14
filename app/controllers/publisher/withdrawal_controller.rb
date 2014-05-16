class Publisher::WithdrawalController < Publisher::ApplicationController
  def index
    billing_service = BillingService.new
    @account = billing_service.publisher_withdrawals_account current_publisher
  end
end
