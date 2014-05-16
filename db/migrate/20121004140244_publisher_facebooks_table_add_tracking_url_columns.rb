class PublisherFacebooksTableAddTrackingUrlColumns < ActiveRecord::Migration
  def self.up
    add_column :publisher_facebooks, :tracking_url_id, :integer
    add_column :publisher_facebooks, :engage_date, :datetime
  end

  def self.down
    remove_column :publisher_facebooks, :tracking_url_id
    remove_column :publisher_facebooks, :engage_date
  end
end
