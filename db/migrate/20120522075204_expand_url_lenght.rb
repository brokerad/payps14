class ExpandUrlLenght < ActiveRecord::Migration
  def self.up
  	change_column :ads, :link, :string, :limit => 1024
  	change_column :posts, :target_url, :string, :limit => 1024
  end
	
  def self.down
  	change_column :ads, :link, :string, :limit => 255
  	change_column :posts, :target_url, :string, :limit => 255
  end
end
