class Campaign80BalanceFix < ActiveRecord::Migration
  def self.up
    campaign_id = 80
    current_budget = 100
    new_budget = 300
    c=Campaign.find(campaign_id)
    c.update_attribute(:budget, current_budget)
    
    c.budget = new_budget
    CampaignService.update(c, current_budget)
  end

  def self.down
    campaign_id = 80
    current_budget = 300
    new_budget = 100
    c=Campaign.find(campaign_id)
    c.budget = new_budget
    CampaignService.update(c, current_budget)
    
    c.update_attribute(:budget, current_budget)
  end
end
