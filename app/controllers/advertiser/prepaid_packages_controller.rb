class Advertiser::PrepaidPackagesController < Advertiser::ApplicationController
  def index
    @prepaid_packages = PrepaidPackage.active.all
  end

  def confirm_buy
    @bank_account = Payment.where(:payment_type => Payment::BANK_ACCOUNT).first
    @prepaid_package = PrepaidPackage.find(params[:id])
  end

  def buy
    billing_service = BillingService.new
    billing_service.buy_package(current_advertiser, PrepaidPackage.find(params[:id]))
    redirect_to advertiser_checking_account_index_path
  end
end
