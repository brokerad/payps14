class PublisherAddNewsletterColumns < ActiveRecord::Migration
  def self.up
    add_column :publishers, :send_newsletters, :boolean, :default => true
    add_column :publishers, :news_use_facebook_email, :boolean, :default => true
    add_column :publishers, :news_alternative_email, :string
  end

  def self.down
    remove_column :publishers, :send_newsletters
    remove_column :publishers, :news_use_facebook_email
    remove_column :publishers, :news_alternative_email
  end
end
