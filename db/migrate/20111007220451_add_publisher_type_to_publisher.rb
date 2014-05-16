class AddPublisherTypeToPublisher < ActiveRecord::Migration
  def self.up
    add_column :publishers, :publisher_type_id, :integer
  end

  def self.down
    remove_column :publishers, :publisher_type_id
  end
end
