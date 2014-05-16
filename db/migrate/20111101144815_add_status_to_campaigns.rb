class AddStatusToCampaigns < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :status, :string
    Campaign.update_all "status = '#{Campaign::SCHEDULED}'"
  end

  def self.down
   remove_column :campaigns, :status
  end
end
