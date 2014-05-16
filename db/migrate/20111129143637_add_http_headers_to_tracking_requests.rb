class AddHttpHeadersToTrackingRequests < ActiveRecord::Migration
  def self.up
    add_column :tracking_requests, :http_headers, :text
    # , :limit => 10000
  end

  def self.down
    remove_column :tracking_requests, :http_headers
  end
end
