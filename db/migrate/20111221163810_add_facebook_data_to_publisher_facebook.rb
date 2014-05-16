class AddFacebookDataToPublisherFacebook < ActiveRecord::Migration
  def self.up
    add_column :publisher_facebooks, :facebook_data, :text
  end

  def self.down
    remove_column :publisher_facebooks, :facebook_data
  end
end
