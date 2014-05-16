class AddPaypalToPublisher < ActiveRecord::Migration
  def self.up
    add_column :publishers, :paypal, :string
  end

  def self.down
    remove_column :publishers, :paypal
  end
end
