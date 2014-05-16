class AddAutopublishingToCampaign < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :autopublishing, :boolean
  end

  def self.down
    remove_column :campaigns, :autopublishing
  end
end
