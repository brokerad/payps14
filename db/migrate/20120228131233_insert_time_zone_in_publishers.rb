class InsertTimeZoneInPublishers < ActiveRecord::Migration
  def self.up
    Publisher.find_all_by_time_zone(nil).each do |publisher|
      publisher.time_zone = "UTC"
      publisher.save!
    end
  end
end
