class EnableAllUsers < ActiveRecord::Migration
  def self.up
    User.update_all(:enabled => true)
  end
end
