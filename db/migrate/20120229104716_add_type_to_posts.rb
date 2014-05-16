class AddTypeToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :source, :string
    ActiveRecord::Base.connection.execute "UPDATE posts SET source = '#{Post::MANUAL}'"
  end

  def self.down
    remove_column :posts, :type
  end
end
