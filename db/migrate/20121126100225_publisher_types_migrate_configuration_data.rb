class PublisherTypesMigrateConfigurationData < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute "
      UPDATE  publisher_types 
      SET commission = publisher_billing_configs.commission, 
          minimal_payment = publisher_billing_configs.minimal_payment, 
          payment_delay = publisher_billing_configs.payment_delay
      FROM publisher_billing_configs
      WHERE publisher_types.id = publisher_billing_configs.publisher_type_id;"
  end

  def self.down
    #no revert script is necessary, because following rollback script will removed all 3 columns
  end
end
