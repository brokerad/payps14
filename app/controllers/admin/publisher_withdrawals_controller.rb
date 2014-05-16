class Admin::PublisherWithdrawalsController < Admin::ApplicationController
  def index
    @publishers = BillingService.new.withdrawal_publishers
  end

  def show
    #TODO Load current publisher by ID
    @publisher = Publisher.all.first
    @campaigns = Campaign.all
  end
end
