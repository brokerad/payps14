class AddTaxNumberToPublisher < ActiveRecord::Migration
  def self.up
    rename_column :publishers, :uniqueid, :tax_number
  end

  def self.down
    rename_column :publishers, :tax_number, :uniqueid
  end
end
