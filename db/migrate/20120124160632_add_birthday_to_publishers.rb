class AddBirthdayToPublishers < ActiveRecord::Migration
  def self.up
    add_column :publishers, :birthday, :string
  end

  def self.down
    remove_column :publishers, :birthday
  end
end
