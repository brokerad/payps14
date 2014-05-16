class AddPaymentInfoToPublisher < ActiveRecord::Migration
  def self.up
    add_column :publishers, :personality, :string  
    add_column :publishers, :uniqueid, :string
    add_column :publishers, :billing_name, :string
    add_column :publishers, :billing_address, :string
  end

  def self.down
    remove_column :publishers, :personality  
    remove_column :publishers, :uniqueid
    remove_column :publishers, :billing_name
    remove_column :publishers, :billing_address
  end
end
