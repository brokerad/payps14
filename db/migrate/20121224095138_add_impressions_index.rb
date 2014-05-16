class AddImpressionsIndex < ActiveRecord::Migration
  def self.up
    add_index :impressions, :id  
  end

  def self.down
    remove_index :impressions, :id    
  end
end
