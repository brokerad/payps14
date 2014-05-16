class UsersUpdateMailAsConfirmedToAllPublisher < ActiveRecord::Migration
  def self.up
    User.update_all({:is_email_confirmed => true},{:role=>User::PUBLISHER})
  end

  def self.down
    User.update_all({:is_email_confirmed => false},{:role=>User::PUBLISHER})
  end
end
