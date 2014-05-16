class CreateAdminVariables < ActiveRecord::Migration
  def self.up
    create_table :admin_variables do |t|
      t.string :key
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_variables
  end
end
