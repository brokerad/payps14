class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name_it
      t.string :name_en
      t.string :name_pt_BR
      t.boolean :active,  :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end
end
