class CreatePrepaidPackages < ActiveRecord::Migration
  def self.up
    create_table :prepaid_packages do |t|
      t.string :package_code
      t.date :start_date
      t.date :end_date
      t.decimal :price
      t.float :discount
      t.decimal :budget

      t.timestamps
    end
  end

  def self.down
    drop_table :prepaid_packages
  end
end
