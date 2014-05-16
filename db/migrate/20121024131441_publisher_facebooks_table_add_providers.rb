class PublisherFacebooksTableAddProviders < ActiveRecord::Migration
  def self.up
    add_column :publisher_facebooks, :providers, :string
  end

  def self.down
    remove_column :publisher_facebooks, :providers
  end
end
