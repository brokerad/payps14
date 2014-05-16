class PartnersRefactory < ActiveRecord::Migration
  def self.up
    add_column :partners, :address, :string
    add_column :partners, :zip, :string
    add_column :partners, :city, :string
    add_column :partners, :country, :string
    add_column :partners, :contact_name, :string
    add_column :partners, :contact_im, :string
    add_column :partners, :tax_code, :string
    add_column :partners, :paypal_account, :string
    add_column :partners, :active, :boolean
  end

  def self.down
    remove_column :partners, :address
    remove_column :partners, :zip
    remove_column :partners, :city
    remove_column :partners, :country
    remove_column :partners, :contact_name
    remove_column :partners, :contact_im
    remove_column :partners, :tax_code
    remove_column :partners, :paypal_account
    remove_column :partners, :active
  end
end
