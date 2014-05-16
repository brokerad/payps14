class RemoveCatrgoryIdFromAds < ActiveRecord::Migration
  def self.up
    remove_column :ads, :category_id
  end

  def self.down
    add_column :ads, :category_id, :integer
  end
end
