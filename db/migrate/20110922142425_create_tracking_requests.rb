class CreateTrackingRequests < ActiveRecord::Migration
  def self.up
    create_table :tracking_requests do |t|
      t.references :tracking_code
      t.string :ip

      t.timestamps
    end
    remove_column :tracking_codes, :count
  end

  def self.down
    drop_table :tracking_requests
    add_column :tracking_codes, :count, :integer, :default => 0
  end
end
