class CreateCampaigns < ActiveRecord::Migration
  def self.up
    create_table :campaigns do |t|
      t.string :name
      t.string :description
      t.timestamp :start_date
      t.timestamp :end_date
      t.references :advertiser

      t.timestamps
    end
  end

  def self.down
    drop_table :campaigns
  end
end
