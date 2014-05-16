class Publisher::RequestPaymentsController < Publisher::ApplicationController
  before_filter :require_publisher_is_ready_for_billing

  def require_publisher_is_ready_for_billing
    unless current_publisher.ready_for_billing?
      flash[:notice] = t("publisher.billing.account_not_ready_for_billing")
      redirect_to publisher_publisher_path(current_publisher)
    end
  end

  def index
    @publisher = current_publisher
  end

  def update
    BillingService.new.request_withdrawal current_publisher
    redirect_to publisher_billing_checking_account_path(current_publisher)
  end
end
