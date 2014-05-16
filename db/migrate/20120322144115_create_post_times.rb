class CreatePostTimes < ActiveRecord::Migration
  def self.up
    create_table :post_times do |t|
      t.integer :post_time
      t.timestamps
    end
  end

  def self.down
    drop_table :post_times
  end
end
