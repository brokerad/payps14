class PartnersAddAdminColumn < ActiveRecord::Migration
  def self.up
    add_column :partners, :admin_id, :integer
    add_index :partners, :admin_id
  end

  def self.down
    remove_column :partners, :admin_id
  end
end
