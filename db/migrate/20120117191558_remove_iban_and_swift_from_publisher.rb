class RemoveIbanAndSwiftFromPublisher < ActiveRecord::Migration
  def self.up
    remove_column :publishers, :iban
    remove_column :publishers, :swift
  end

  def self.down
    add_column :publishers, :iban, :string
    add_column :publishers, :swift, :string
  end
end
