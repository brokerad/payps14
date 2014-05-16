class Advertiser::TransactionsController < Advertiser::ApplicationController
  def index
    billing_service = BillingService.new
    @account = billing_service.advertiser_receivables_account(current_advertiser)
  end
end
