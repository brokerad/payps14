class CreateCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupons do |t|
      t.string   :name
      t.string   :code
      t.integer :total
      t.date     :from_date
      t.date     :to_date
      t.decimal :amount
      t.integer :partner_id

      t.timestamps
    end
  end

  def self.down
    drop_table :coupons
  end
end
