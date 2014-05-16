class AddPublisherTypeToPublisherBillingConfigs < ActiveRecord::Migration
  def self.up
    add_column :publisher_billing_configs, :publisher_type_id, :integer
  end

  def self.down
    remove_column :publisher_billing_configs, :publisher_type_id
  end
end
