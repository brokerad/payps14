class CreateTrackingCodes < ActiveRecord::Migration
  def self.up
    create_table :tracking_codes do |t|
      t.references :post
      t.string :target_url
      t.integer :count, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :tracking_codes
  end
end
