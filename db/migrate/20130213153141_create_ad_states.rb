class CreateAdStates < ActiveRecord::Migration
  def self.up
    create_table :ad_states do |t|
      t.integer :ad_id
      t.string :state, :default => "pending"
      t.string :message

      t.timestamps
    end
  end

  def self.down
    drop_table :ad_states
  end
end
