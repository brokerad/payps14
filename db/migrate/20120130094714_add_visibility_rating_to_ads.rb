class AddVisibilityRatingToAds < ActiveRecord::Migration
  def self.up
    add_column :ads, :visibilityrating, :string
    Ad.update_all "visibilityrating = '#{Ad::G}'"
  end

  def self.down
    remove_column :ads, :visibilityrating
  end
end

