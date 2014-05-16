class AddEnabledToPublishers < ActiveRecord::Migration
  def self.up
    add_column :publishers, :enabled, :boolean, { :default => false }
  end

  def self.down
    remove_column :publishers, :enabled
  end
end
