class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.string :payment_type
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
