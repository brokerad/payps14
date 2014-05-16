class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.string :place_type
      t.string :name
      t.integer :friends
      t.integer :fans
      t.references :publisher
      t.references :placeable, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :places
  end
end
