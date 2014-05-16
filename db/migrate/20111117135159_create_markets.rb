class CreateMarkets < ActiveRecord::Migration
  def self.up
    create_table :markets do |t|
      t.string :name
      t.text :description

      t.timestamps
    end

    create_table :publisher_markets do |t|
      t.references :publisher
      t.references :market
      t.timestamps
    end
  end

  def self.down
    drop_table :markets
  end
end
