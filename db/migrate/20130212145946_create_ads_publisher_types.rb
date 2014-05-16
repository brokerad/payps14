class CreateAdsPublisherTypes < ActiveRecord::Migration
  def self.up
    create_table :ads_publisher_types, :id => false do |t|
      t.integer :ad_id
      t.integer :publisher_type_id
    end
  end

  def self.down
    drop_table :ads_publisher_types
  end
end
