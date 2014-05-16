class AddFbEmailToPublisherFacebooks < ActiveRecord::Migration
  def self.up
    add_column :publisher_facebooks, :fb_email, :string
  end

  def self.down
    remove_column :publisher_facebooks, :fb_email
  end
end
