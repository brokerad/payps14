class DropPublisherBillingConfigsTable < ActiveRecord::Migration
  def self.up
    drop_table :publisher_billing_configs
  end

  def self.down
    create_table :publisher_billing_configs do |t|
      t.integer :commission
      t.decimal :minimal_payment, :precision => 8, :scale => 2
      t.integer :payment_delay
      t.integer :publisher_type_id

      t.timestamps
    end
  end
end
