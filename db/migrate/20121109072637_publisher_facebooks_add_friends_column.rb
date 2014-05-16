class PublisherFacebooksAddFriendsColumn < ActiveRecord::Migration
  def self.up
    add_column :publisher_facebooks, :friends, :integer, :default => 0
  end

  def self.down
    remove_column :publisher_facebooks, :friends
  end
end
