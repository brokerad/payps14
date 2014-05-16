class RemovePublisherIdFromPosts < ActiveRecord::Migration
  def self.up
    remove_column :posts, :publisher_id
  end

  def self.down
    add_column :posts, :publisher_id, :integer
  end
end
