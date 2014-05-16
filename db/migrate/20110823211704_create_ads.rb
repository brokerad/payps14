class CreateAds < ActiveRecord::Migration
  def self.up
    create_table :ads do |t|
      t.string :message
      t.string :link
      t.string :picture_link
      t.string :link_name
      t.string :link_caption
      t.string :link_description
      t.references :advertiser

      t.timestamps
    end
  end

  def self.down
    drop_table :ads
  end
end
