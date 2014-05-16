class AddRefererToAdvertiser < ActiveRecord::Migration
  def self.up
    add_column :advertisers, :referer, :text
  end

  def self.down
    remove_column :advertisers, :referer
  end
end
