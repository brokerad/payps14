class CreateTrackingUrls < ActiveRecord::Migration
  def self.up
    create_table :tracking_urls do |t|
      t.integer :partner_id
      t.string :lead_url
      t.string :name
      t.string :tracking_code
      t.boolean :active, :default => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :tracking_urls
  end
end
