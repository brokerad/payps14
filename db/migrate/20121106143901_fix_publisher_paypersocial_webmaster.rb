class FixPublisherPaypersocialWebmaster < ActiveRecord::Migration
  def self.up
    if user = User.where(:email => 'paypersocial.webmaster@gmail.com').first
      unless user.publisher
        user.publisher = Publisher.new
        user.publisher.enabled = true
        user.publisher.email = user.email
        # publisher.user = user
        user.publisher.save
      end
    end
  end

  def self.down
    if user = User.where(:email => 'paypersocial.webmaster@gmail.com').first
      if user.publisher
        user.publisher.destroy
      end
    end
  end
end
