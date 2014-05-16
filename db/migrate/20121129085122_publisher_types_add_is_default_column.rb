class PublisherTypesAddIsDefaultColumn < ActiveRecord::Migration
  def self.up
    add_column :publisher_types, :is_default, :boolean, :default => false
  end

  def self.down
    remove_column :publisher_types, :is_default
  end
end
