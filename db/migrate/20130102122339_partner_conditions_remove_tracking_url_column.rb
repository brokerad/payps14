class PartnerConditionsRemoveTrackingUrlColumn < ActiveRecord::Migration
  def self.up
    remove_column :partner_conditions, :tracking_url_id
  end

  def self.down
    add_column :partner_conditions, :tracking_url_id, :integer
  end
end
