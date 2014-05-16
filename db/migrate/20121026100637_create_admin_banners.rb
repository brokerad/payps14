class CreateAdminBanners < ActiveRecord::Migration
  def self.up
    create_table :banners do |t|
      t.string :name
      t.integer :language_id
      t.integer :page
      t.string :target_url
      t.boolean :active, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :banners
  end
end
