class ChangePublisherBirthdayDatatype < ActiveRecord::Migration
  def self.up
    remove_column :publishers, :birthday
    add_column :publishers, :birthday, :date
  end

  def self.down
    remove_column :publishers, :birthday
    add_column :publishers, :birthday, :string
  end
end
