class CreatePartners < ActiveRecord::Migration
  def self.up
    create_table :partners do |t|
      t.string :lead_url
      t.string :name
      t.string :partner_tracking_code

      t.timestamps
    end
  end

  def self.down
    drop_table :partners
  end
end
