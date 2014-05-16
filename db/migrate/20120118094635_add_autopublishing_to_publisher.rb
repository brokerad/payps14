class AddAutopublishingToPublisher < ActiveRecord::Migration
  def self.up
    add_column :publishers, :autopublishing, :boolean
  end

  def self.down
    remove_column :publishers, :autopublishing
  end
end
