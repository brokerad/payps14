class AddIsoCodeToMarkets < ActiveRecord::Migration
  def self.up
    add_column :markets, :iso_code, :string
  end

  def self.down
    remove_column :markets, :iso_code
  end
end
