class PublisherFacebooksTableAddTrackingUrlColumnsIndexes < ActiveRecord::Migration
  def self.up
    add_index :publisher_facebooks, :tracking_url_id
    add_index :publisher_facebooks, :engage_date
  end
  
  def self.down
    remove_index :publisher_facebooks, :tracking_url_id
    remove_index :publisher_facebooks, :engage_date
  end
end
