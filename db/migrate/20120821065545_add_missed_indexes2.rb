class AddMissedIndexes2 < ActiveRecord::Migration
  def self.up
    add_index :ad_has_categories, :ad_id
    add_index :ad_has_categories, :category_id
    
    add_index :ads, :campaign_id
    add_index :advertisers, :user_id
    
    add_index :coupons, :code
    add_index :coupons, :partner_id
    
    add_index :entries, :account_id
    add_index :entries, :transaction_id
    add_index :entries, :reconciled
    
    add_index :places, :place_type
    add_index :places, :publisher_facebook_id
    
    add_index :publisher_facebooks, :email
    add_index :publisher_facebooks, :publisher_id
  end
  
  def self.down
    remove_index :ad_has_categories, :ad_id
    remove_index :ad_has_categories, :category_id
    
    remove_index :ads, :campaign_id
    remove_index :advertisers, :user_id
    
    remove_index :coupons, :code
    remove_index :coupons, :partner_id
    
    remove_index :entries, :account_id
    remove_index :entries, :transaction_id
    remove_index :entries, :reconciled
    
    remove_index :places, :place_type
    remove_index :places, :publisher_facebook_id
    
    remove_index :publisher_facebooks, :email
    remove_index :publisher_facebooks, :publisher_id
  end
  
end
