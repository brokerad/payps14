class PlacesTableAddUidColumn < ActiveRecord::Migration
  def self.up
    add_column :places, :uid, :string
    add_index :places, :uid
  end

  def self.down
    remove_column :places, :uid
  end
end
