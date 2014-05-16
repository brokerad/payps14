class Advertiser::CheckingAccountController < Advertiser::ApplicationController
  def index
    billing_service = BillingService.new
    @account = billing_service.advertiser_checking_account(current_advertiser)
  end
end
