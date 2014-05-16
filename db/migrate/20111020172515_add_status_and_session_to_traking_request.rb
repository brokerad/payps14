class AddStatusAndSessionToTrakingRequest < ActiveRecord::Migration
  def self.up
    add_column :tracking_requests, :session_id, :string
    add_column :tracking_requests, :status, :string
  end

  def self.down
    remove_column :tracking_requests, :session_id
    remove_column :tracking_requests, :status
  end
end
