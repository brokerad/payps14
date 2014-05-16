class AddDatesToAds < ActiveRecord::Migration
  def self.up
  	add_column :ads, :start_date, :timestamp
  	add_column :ads, :end_date, :timestamp
  	
  	ads = Ad.all
  	ads.each do |ad|
  		ad.start_date = ad.campaign.start_date
  		ad.end_date = ad.campaign.end_date
  		ad.save
  	end
  end

  def self.down
  	remove_column :ads, :start_date
  	remove_column :ads, :end_date
  end
end
