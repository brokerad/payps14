class RemoveEnableFromAdvertiser < ActiveRecord::Migration
  def self.up
    remove_column :advertisers, :enabled
  end

  def self.down
    add_column :advertisers, :enabled, :boolean, :default => false
  end
end
