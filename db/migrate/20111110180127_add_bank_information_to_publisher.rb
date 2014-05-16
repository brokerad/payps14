class AddBankInformationToPublisher < ActiveRecord::Migration
  def self.up
    add_column :publishers, :iban, :string
    add_column :publishers, :swift, :string
    add_column :publishers, :bithday, :date
    add_column :publishers, :document_number, :string
  end

  def self.down
    remove_column :publishers, :document_number
    remove_column :publishers, :bithday
    remove_column :publishers, :swift
    remove_column :publishers, :iban
  end
end
