class PublisherTypesAddConfigRelatedColumns < ActiveRecord::Migration
  def self.up
    add_column :publisher_types, :commission, :integer
    add_column :publisher_types, :minimal_payment, :decimal, :precision => 8, :scale => 2
    add_column :publisher_types, :payment_delay, :integer    
  end

  def self.down
    remove_column :publisher_types, :commission
    remove_column :publisher_types, :minimal_payment
    remove_column :publisher_types, :payment_delay
  end
end
