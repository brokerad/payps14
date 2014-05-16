class MoveCategoryIdFromCampaignToAd < ActiveRecord::Migration
  def self.up
    remove_column :campaigns, :category_id
    add_column :ads, :category_id, :integer
  end

  def self.down
    add_column :campaigns, :category_id, :integer
    remove_column :ads, :category_id
  end
end
