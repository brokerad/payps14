require 'spec_helper'

describe CampaignService do
  
  context 'process campaign' do
    it 'with partner conditions available' do
      Rails.cache.clear
      create_billing_system
      read_billing_system

      publisher = Factory(:publisher_engaged, :engage_date => Time.now.utc)
      publisher_fb = Factory(:publisher_facebook_engaged, :publisher => publisher)
      place = Factory(:place, :publisher_facebook => publisher_fb)
      post = Factory(:post, :place => place)
      campaign = post.ad.campaign
      partner_revenue = 10
      
      BillingService.new.buy_package(campaign.advertiser, Factory(:prepaid_package))
      pending_transaction_string = "Pending buy credit to advertiser #{post.ad.campaign.advertiser.id}"
      transaction = Transaction.where("description like '%#{pending_transaction_string}%'").first
      BillingService.new.confirm_advertiser_payment(transaction)
      BillingService.new.transfer_to_campaign(campaign, campaign.budget)
      
      Factory(:revenue_share, :tracking_url => publisher.tracking_url, 
        :start_date => Time.now.utc + 1.days, :end_date => Time.now.utc + 11.days, 
        :duration => 10, :revenue => partner_revenue)
      
      # 1 click out of the range (another campaign)
      # 3 valid clicks for campaign
      # 2 from 3 (campaigns' clicks) valid for revenue share
      Factory(:tracking_request, :created_at => Time.now.utc - 4.days)      
      clicks = [Factory(:tracking_request, :post => post, :created_at => Time.now.utc - 3.days), 
                Factory(:tracking_request, :post => post, :created_at => Time.now.utc - 1.days),
                Factory(:tracking_request, :post => post, :created_at => Time.now.utc - 1.days)]
      
      
      ti = Paypersocial::TimeInterval::TimeIntervalHolder.new(Time.now.utc - 2.days, Time.now.utc + 1.days)
      Publisher.any_instance.stub(:get_eligible_time_interval).with(post.ad.campaign).and_return(ti)
      
      CampaignService.process(post.ad.campaign)
      transaction = Transaction.where("description like '%Processed campaign #{campaign.id}%'").first
      transaction.entries.count.should eq 5
      
      clicks_amount = (clicks.count*campaign.click_value).round(2, BigDecimal::ROUND_DOWN)
      commission = (clicks_amount*publisher.publisher_type.commission/100).round(2, BigDecimal::ROUND_DOWN)
      publisher_income = clicks_amount - commission
      
      partner_clicks_amount = ((clicks.count-1)*campaign.click_value).round(2, BigDecimal::ROUND_DOWN)
      partner_commission = (partner_clicks_amount*publisher.publisher_type.commission/100).round(2, BigDecimal::ROUND_DOWN)
      partner_income = ((partner_clicks_amount-partner_commission)*partner_revenue/100).round(2, BigDecimal::ROUND_DOWN)

      pps_income = commission - partner_income
      campaign_cash_back = campaign.budget-pps_income-publisher_income-partner_income
      
      entries_result = [pps_income, publisher_income, partner_income, campaign_cash_back, campaign.budget*(-1)]
      transaction.entries.each do |entry| 
        entries_result.should include(entry.amount)
        entries_result.delete(entry.amount)
      end
      entries_result.should be_empty
    end
    
    def get_account(entry)
      return account if (account = BillingService.new.campaign_checking_account(campaign)).name.to_i == entry.account_id
    end
  end
  
end
