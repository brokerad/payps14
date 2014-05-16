class AddClickValueToCampaign < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :click_value, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :campaigns, :click_value
  end
end
