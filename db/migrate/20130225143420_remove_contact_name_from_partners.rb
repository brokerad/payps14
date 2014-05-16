class RemoveContactNameFromPartners < ActiveRecord::Migration
  def self.up
    remove_column :partners, :contact_name
  end

  def self.down
    add_column :partners, :contact_name, :string
  end
end
