class AddMaxClicksPerDayAndMaxPendingClicksPerDayToCampaign < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :max_clicks_per_day, :integer
    add_column :campaigns, :max_pending_clicks_per_day, :integer
  end

  def self.down
    remove_column :campaigns, :max_clicks_per_day
    remove_column :campaigns, :max_pending_clicks_per_day
  end
end
