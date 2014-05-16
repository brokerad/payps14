class AddPostsPlaceIdAndPlacesPublisherIdIndexes < ActiveRecord::Migration
  def self.up
    add_index :posts, :place_id
    add_index :places, :publisher_id
  end

  def self.down
    remove_index :posts, :place_id
    remove_index :places, :publisher_id
  end
end
