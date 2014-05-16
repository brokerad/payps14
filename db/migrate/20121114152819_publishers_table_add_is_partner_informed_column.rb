class PublishersTableAddIsPartnerInformedColumn < ActiveRecord::Migration
  def self.up
    add_column :publishers, :is_partner_informed, :boolean, :default => false
  end

  def self.down
    remove_column :publishers, :is_partner_informed
  end
end
