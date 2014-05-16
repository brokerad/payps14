class RemoveAdvertiserIdFromAds < ActiveRecord::Migration
  def self.up
    remove_column :ads, :advertiser_id
  end

  def self.down
    add_column :ads, :advertiser_id, :integer
  end
end
