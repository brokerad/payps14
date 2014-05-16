class PublisherColumnNewsUseFacebookEmailUpdateToTrue < ActiveRecord::Migration
  def self.up
    Publisher.update_all({:news_use_facebook_email => true})
  end

  def self.down
    Publisher.update_all({:news_use_facebook_email => nil})
  end
end
