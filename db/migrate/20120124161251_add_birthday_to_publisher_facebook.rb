class AddBirthdayToPublisherFacebook < ActiveRecord::Migration
  def self.up
    add_column :publisher_facebooks, :birthday, :string
  end

  def self.down
    remove_column :publisher_facebooks, :birthday
  end
end
