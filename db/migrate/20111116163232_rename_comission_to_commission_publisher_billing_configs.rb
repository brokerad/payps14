class RenameComissionToCommissionPublisherBillingConfigs < ActiveRecord::Migration
  def self.up
    rename_column :publisher_billing_configs, :comission, :commission
  end

  def self.down
    rename_column :publisher_billing_configs, :commission, :comission
  end
end
