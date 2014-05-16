class ChangeCampaignFields < ActiveRecord::Migration
  def self.up
    remove_column :campaigns, :max_pending_clicks_per_day
  end

  def self.down
    add_column :campaigns, :max_pending_clicks_per_day, :integer
  end
end
