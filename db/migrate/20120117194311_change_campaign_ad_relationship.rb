class ChangeCampaignAdRelationship < ActiveRecord::Migration
  def self.up
    add_column :ads, :campaign_id, :integer, :null => true
    execute "UPDATE ads
             SET campaign_id = (SELECT campaign_id
                                FROM campaigns_ads
                                WHERE ad_id = ads.id)"
    change_column :ads, :campaign_id, :integer, :null => false
    execute "ALTER TABLE ads ADD CONSTRAINT ads_campaigns_fk FOREIGN KEY (campaign_id) REFERENCES campaigns (id)"
    drop_table :campaigns_ads
  end

  def self.down
    create_table :campaigns_ads do |t|
      t.references :campaign
      t.references :ad

      t.timestamps
    end
    execute "INSERT INTO campaigns_ads (campaign_id, ad_id, created_at, updated_at)
             SELECT campaign_id, id, now(), now()
             FROM ads"
    remove_column :ads, :campaign_id
  end
end
