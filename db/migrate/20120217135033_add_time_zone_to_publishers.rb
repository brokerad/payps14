class AddTimeZoneToPublishers < ActiveRecord::Migration
  def self.up
    add_column :publishers, :time_zone, :string
  end

  def self.down
    remove_column :publishers, :time_zone
  end
end
