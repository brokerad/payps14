class CreatePublisherBillingConfigs < ActiveRecord::Migration
  def self.up
    create_table :publisher_billing_configs do |t|
      t.integer :comission
      t.decimal :minimal_payment, :precision => 8, :scale => 2
      t.integer :payment_delay

      t.timestamps
    end
  end

  def self.down
    drop_table :publisher_billing_configs
  end
end
