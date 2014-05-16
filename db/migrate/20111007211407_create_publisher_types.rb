class CreatePublisherTypes < ActiveRecord::Migration
  def self.up
    create_table :publisher_types do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :publisher_types
  end
end
