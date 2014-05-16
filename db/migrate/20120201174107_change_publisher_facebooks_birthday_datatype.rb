class ChangePublisherFacebooksBirthdayDatatype < ActiveRecord::Migration
  def self.up
    remove_column :publisher_facebooks, :birthday
    add_column :publisher_facebooks, :birthday, :date
  end

  def self.down
    remove_column :publisher_facebooks, :birthday
    add_column :publisher_facebooks, :birthday, :string
  end
end
