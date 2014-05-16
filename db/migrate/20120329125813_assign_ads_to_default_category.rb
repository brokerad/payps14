class AssignAdsToDefaultCategory < ActiveRecord::Migration
  def self.up
  	default_category = Category.create!(:name_it => 'PayPerSocial', :name_en => 'PayPerSocial', :name_pt_BR => 'PayPerSocial', :active => true)
  	uncategorised_ads = Ad.find(:all, :conditions => ['ads.id NOT IN (SELECT ads.id FROM ads INNER JOIN ad_has_categories ON ads.id = ad_has_categories.ad_id)']) 
  	
  	uncategorised_ads.each do |ad|
  		ad.categories = [default_category]
  		ad.save
  	end
  end

  def self.down
  	category = Category.find_by_name_it("PayPerSocial")  	
		AdHasCategory.delete_all("category_id = #{category.id}")		
		category.delete
  end
end
