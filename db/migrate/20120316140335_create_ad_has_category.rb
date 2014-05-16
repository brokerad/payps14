class CreateAdHasCategory < ActiveRecord::Migration
  def self.up
    create_table :ad_has_categories do |t|
      t.integer :ad_id
      t.integer :category_id

      t.timestamps
    end
  end

  def self.down
    drop_table :ad_has_categories
  end
end
