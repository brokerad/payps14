class SetFbEmailForPublisherFacebooks < ActiveRecord::Migration
  def self.up
    PublisherFacebook.find_each do |p|
      p.update_attributes(:fb_email => p.facebook_email)
    end
  end

  def self.down
  end
end
