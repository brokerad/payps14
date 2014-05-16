class CreatePublisherNotification < ActiveRecord::Migration
  def self.up
    create_table :publisher_notifications do |t|
      t.string :title
      t.text :notification_text
      t.string :details
      t.timestamps
    end
  end

  def self.down
    drop_table :publisher_notifications
  end
end
