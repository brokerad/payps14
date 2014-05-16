class AddUserToPublisher < ActiveRecord::Migration
  def self.up
    add_column :publishers, :user_id, :integer
  end

  def self.down
    remove_column :publishers, :user_id
  end
end
