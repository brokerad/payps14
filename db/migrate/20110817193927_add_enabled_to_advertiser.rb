class AddEnabledToAdvertiser < ActiveRecord::Migration
  def self.up
    add_column :advertisers, :enabled, :boolean, :default => false
  end

  def self.down
    remove_column :advertisers, :enabled
  end
end
