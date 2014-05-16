class PublisherColumnSendNewslettersUpdateToTrue < ActiveRecord::Migration
  def self.up
    Publisher.update_all({:send_newsletters => true})
  end

  def self.down
    Publisher.update_all({:send_newsletters => nil})
  end
end
