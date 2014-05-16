class PublishersAddEngageDateColumnAndIndex < ActiveRecord::Migration
  def self.up
    add_column :publishers, :engage_date, :datetime
    add_index :publishers, :engage_date
  end

  def self.down
    remove_column :publishers, :engage_date
  end
end
