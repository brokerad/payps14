class AddShowHomepageToAds < ActiveRecord::Migration
  def self.up
    add_column :ads, :show_homepage, :boolean, :default => true
    Ad.update_all :show_homepage => true
  end

  def self.down
    remove_column :ads, :show_homepage
  end
end
