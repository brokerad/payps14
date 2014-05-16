class AddEnabledToPlaces < ActiveRecord::Migration
  def self.up
    add_column :places, :enabled, :boolean
  end

  def self.down
    remove_column :places, :enabled
  end
end
