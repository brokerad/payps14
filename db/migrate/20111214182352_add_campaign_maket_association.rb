class AddCampaignMaketAssociation < ActiveRecord::Migration
  def self.up
    create_table :market_campaigns do |t|
      t.references :market
      t.references :campaign
      t.timestamps
    end
  end

  def self.down
    drop_table :market_campaigns
  end
end
