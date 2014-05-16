class PublisherAddAdminColumn < ActiveRecord::Migration
  def self.up
    add_column :publishers, :admin_id, :integer
    add_index :publishers, :admin_id
  end

  def self.down
    remove_column :publishers, :admin_id
  end
end
