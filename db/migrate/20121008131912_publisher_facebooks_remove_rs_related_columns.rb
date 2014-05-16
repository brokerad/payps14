class PublisherFacebooksRemoveRsRelatedColumns < ActiveRecord::Migration
  def self.up
    remove_column :publisher_facebooks, :tracking_url_id
    remove_column :publisher_facebooks, :engage_date
  end

  def self.down
    add_column :publisher_facebooks, :tracking_url_id, :integer
    add_column :publisher_facebooks, :engage_date, :datetime
    add_index :publisher_facebooks, :tracking_url_id
    add_index :publisher_facebooks, :engage_date
  end
end
