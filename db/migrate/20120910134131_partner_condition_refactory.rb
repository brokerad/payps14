class PartnerConditionRefactory < ActiveRecord::Migration
  def self.up
    add_column :partner_conditions, :tracking_url_id, :integer
    add_column :partner_conditions, :end_date, :date
    add_column :partner_conditions, :active, :boolean, :default => true    
  end

  def self.down
    remove_column :partner_conditions, :tracking_url_id      
    remove_column :partner_conditions, :end_date      
    remove_column :partner_conditions, :active      
    remove_column :partner_conditions, :partner_id
  end
end
