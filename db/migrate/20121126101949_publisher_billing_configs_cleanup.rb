class PublisherBillingConfigsCleanup < ActiveRecord::Migration
  def self.up
    #no setup script is necessary, because this script si just for rollback cases
  end

  def self.down
    ActiveRecord::Base.connection.execute "
      INSERT INTO publisher_billing_configs (publisher_type_id, commission, minimal_payment, payment_delay)
      SELECT id, commission, minimal_payment, payment_delay FROM publisher_types"
  end
end
