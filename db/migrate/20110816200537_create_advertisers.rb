class CreateAdvertisers < ActiveRecord::Migration
  def self.up
    create_table :advertisers do |t|
      t.string :company_name
      t.string :address
      t.string :city
      t.string :country
      t.string :zip_code
      t.string :phone
      t.string :fax
      t.string :site

      t.timestamps
    end
  end

  def self.down
    drop_table :advertisers
  end
end
