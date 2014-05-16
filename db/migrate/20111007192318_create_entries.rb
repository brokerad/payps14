class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.decimal :amount, :precision => 8, :scale => 2
      t.string :description
      t.references :account
      t.references :transaction
      t.boolean :reconciled

      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
