class CreatePartnerConditions < ActiveRecord::Migration
  def self.up
    create_table :partner_conditions do |t|
      t.integer :revenue
      t.date :start_date
      t.integer :duration
      t.integer :partner_id

      t.timestamps
    end
  end

  def self.down
    drop_table :partner_conditions
  end
end