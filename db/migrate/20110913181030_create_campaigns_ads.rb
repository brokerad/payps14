class CreateCampaignsAds < ActiveRecord::Migration
  def self.up
    create_table :campaigns_ads do |t|
      t.references :campaign
      t.references :ad

      t.timestamps
    end
  end

  def self.down
    drop_table :campaigns_ads
  end
end
