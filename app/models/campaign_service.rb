require 'paypersocial'
require 'paypersocial/error/campaign_exceed_budget_error'
require 'paypersocial/error/pending_request_error'

module CampaignService
  #TODO: add transaction!!!
  include Paypersocial
  def self.save campaign
    service = BillingService.new
    balance = service.advertiser_balance campaign.advertiser
    if balance >= campaign.budget
      if campaign.save
        service.create_campaign_accounts(campaign)
        service.transfer_to_campaign(campaign, campaign.budget)
        true
      else
        false
      end
    else
      campaign.errors.add(:budget, I18n.t("campaign.created.no_budget", :budget => campaign.budget, :balance => balance))
      false
    end
  end

  def self.update(campaign, old_budget)
    service = BillingService.new
    balance = service.advertiser_balance(campaign.advertiser)
    budget_difference = campaign.budget - old_budget

    if balance >= budget_difference
      campaign.transaction do
        campaign.save
        service.modify_amount_to_campaign_budget(campaign, budget_difference) if budget_difference != 0
        true
      end
    else
      campaign.errors.add(:budget, I18n.t("campaign.created.no_budget", :budget => campaign.budget, :balance => (balance + old_budget)))
      false
    end
  end

  def self.process(campaign)
    if pending_tracking_requests?(campaign)
      raise Error::PendingRequestError.new(I18n.t("campaign.billing.pending_requests_exist", :id => campaign.id))
    end
    publishers_payable_clicks = campaign.publishers_payable_clicks
    necessary_amount = self.get_clicks_qty_to_process(publishers_payable_clicks) * campaign.click_value
    if necessary_amount > campaign.budget
      raise Error::CampaignExceedBudgetError.new(I18n.t("campaign.billing.exceed_budget", 
        :id => campaign.id, :budget => campaign.budget, :to_pay => necessary_amount))
    end
    BillingService.new.create_campaign_payment_transaction(campaign, publishers_payable_clicks)
    campaign.status = Campaign::PROCESSED
    campaign.save!
  end
  
  def self.reprocess_campaign(campaign)
    not_processed_publishers = self.get_not_processed_publishers(campaign)
    clicks_qty_to_process = self.get_clicks_qty_to_process(not_processed_publishers)
    return false if clicks_qty_to_process == 0 # nothing to process
    
    necessary_amount = clicks_qty_to_process * campaign.click_value
    billing_service = BillingService.new
    advertiser_funds = billing_service.advertiser_balance(campaign.advertiser)
    if necessary_amount > advertiser_funds
      raise Error::CampaignExceedBudgetError.new(I18n.t("campaign.reprocess.exceed_budget",
        :id => campaign.advertiser.id, :budget => advertiser_funds, :to_pay => necessary_amount))
    else
      ActiveRecord::Base.transaction do
        billing_service.transfer_to_campaign(campaign, necessary_amount)
        billing_service.create_campaign_payment_transaction(campaign, not_processed_publishers)
      end
    end
  end
  
  def self.get_clicks_qty_to_process(publishers)
    publishers.inject(0) {|sum, pub| sum + pub['payable_clicks_qty'].to_i}
  end
  
  def self.get_not_processed_publishers(campaign)
    not_processed_publishers = []
    transactions = self.get_processed_transactions(campaign)
    processed_publishers = self.get_processed_publishes(transactions)
    campaign.publishers_payable_clicks.each do |publisher|
      not_processed_publishers << publisher unless processed_publishers.include?(publisher.id)
    end
    not_processed_publishers
  end
  
  def self.get_processed_publishes(transactions)
    publishers = []
    transactions.each do |transaction|
      transaction.entries.each do |entry|
        publishers << entry.account.name.to_i if  entry.account && entry.account.parent == BillingService.new.publishers_checking_account_parent
      end
    end
    publishers
  end
  
  def self.get_processed_transactions(campaign)
    Transaction.where( "description like ?", "Processed campaign #{campaign.id}")
  end
  
  def self.payable_campaigns publisher
    #TODO: Discuss with Fabio
    #      This method definition is wrong, there is no link between publisher's
    #      payment and the campaigns
    #      Should we show publishers' withdraw's account instead?
=begin
    service = BillingService.new
    checking_account = service.publisher_checking_account publisher

    checking_account.unreconciled_entries.collect do |e|
      campaign_entry = e.transaction.entries.select do |entry|
        entry.account.parent == service.campaigns_checking_account_parent #this method was removed from BillingService
      end.first
      Campaign.find campaign_entry.account.name
    end
=end
    []
  end

  private

  def self.pending_tracking_requests?(campaign)
    ds = ActiveRecord::Base.connection.execute "
      SELECT COUNT(*) AS pending_qty
      FROM tracking_requests, posts, ads
      WHERE tracking_requests.post_id = posts.id
        AND posts.ad_id = ads.id
        AND ads.campaign_id = #{campaign.id}
        AND tracking_requests.status = '#{TrackingRequest::PENDING_APPROVAL}'"
    ds.first["pending_qty"].to_i != 0
  end
end
