class CreatePublishers < ActiveRecord::Migration
  def self.up
    create_table :publishers do |t|
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :zip_code
      t.string :city
      t.string :state
      t.string :country
      t.string :email
      t.string :phone
      t.timestamps
    end
  end

  def self.down
    drop_table :publishers
  end
end
