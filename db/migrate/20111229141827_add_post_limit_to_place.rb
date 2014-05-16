class AddPostLimitToPlace < ActiveRecord::Migration
  def self.up
    add_column :places, :post_limit, :integer, :default => 2
  end

  def self.down
    remove_column :places, :post_limit
  end
end
