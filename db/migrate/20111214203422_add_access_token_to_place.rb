class AddAccessTokenToPlace < ActiveRecord::Migration
  def self.up
    add_column :places, :access_token, :string
  end

  def self.down
    remove_column :places, :access_token
  end
end
