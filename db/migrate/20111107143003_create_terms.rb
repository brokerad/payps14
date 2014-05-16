class CreateTerms < ActiveRecord::Migration
  def self.up
    create_table :terms do |t|
      t.text :content
      t.string :title
      t.boolean :enabled, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :terms
  end
end
