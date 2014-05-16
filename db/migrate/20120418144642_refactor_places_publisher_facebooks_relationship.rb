class RefactorPlacesPublisherFacebooksRelationship < ActiveRecord::Migration
  def self.up
  	remove_column :places, :placeable_type
  	rename_column :places, :placeable_id, :publisher_facebook_id
  end

  def self.down
  	add_column :places, :placeable_type, :varchar  
  	rename_column :places, :publisher_facebook_id, :placeable_id
  end
end
