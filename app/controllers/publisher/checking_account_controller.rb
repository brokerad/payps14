class Publisher::CheckingAccountController < Publisher::ApplicationController
  def index
    billing_service = BillingService.new
    @account = billing_service.publisher_checking_account current_publisher
  end
end
