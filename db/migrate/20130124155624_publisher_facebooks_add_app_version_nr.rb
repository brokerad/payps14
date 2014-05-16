class PublisherFacebooksAddAppVersionNr < ActiveRecord::Migration
  def self.up
    add_column :publisher_facebooks, :app_version, :string
    add_column :publisher_facebooks, :app_version_date, :datetime
  end

  def self.down
    remove_column :publisher_facebooks, :app_version
    remove_column :publisher_facebooks, :app_version_date
  end
end
