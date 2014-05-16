class RemoveBithdayFromPublisher < ActiveRecord::Migration
  def self.up
    remove_column :publishers, :bithday
  end

  def self.down
    add_column :publishers, :bithday, :date
  end
end
