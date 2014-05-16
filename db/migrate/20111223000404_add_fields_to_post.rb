class AddFieldsToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :reference_id, :string
    add_column :posts, :likes, :integer, :default => 0
    add_column :posts, :comments, :integer, :default => 0
    add_column :posts, :link, :string
    add_column :posts, :place_id, :integer
  end

  def self.down
    remove_column :posts, :comments
    remove_column :posts, :likes
    remove_column :posts, :reference_id
    remove_column :posts, :link
    remove_column :posts, :place_id
  end
end
