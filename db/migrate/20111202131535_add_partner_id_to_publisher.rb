class AddPartnerIdToPublisher < ActiveRecord::Migration
  def self.up
    add_column :publishers, :partner_id, :integer
  end

  def self.down
    remove_column :publishers, :partner_id
  end
end
