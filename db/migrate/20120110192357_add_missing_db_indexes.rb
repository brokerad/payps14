class AddMissingDbIndexes < ActiveRecord::Migration
  def self.up
    add_index :accounts,                  [:parent_id, :name],                              :unique => true
    add_index :languages,                 :code,                                            :unique => true
    add_index :languages,                 :name,                                            :unique => true
    add_index :partners,                  :partner_tracking_code,                           :unique => true
    add_index :publisher_billing_configs, :publisher_type_id,                               :unique => true
    add_index :publisher_facebooks,       :token,                                           :unique => true
    add_index :publisher_facebooks,       :uid,                                             :unique => true
    add_index :publisher_types,           :name,                                            :unique => true
    remove_index :users,                  :email
    add_index :users,                     :email,                                           :unique => true
    add_index :users,                     :perishable_token,                                :unique => true
    remove_index :users,                  :persistence_token
    add_index :users,                     :persistence_token,                               :unique => true
  end

  def self.down
    remove_index :accounts,                  [:parent_id, :name]
    remove_index :languages,                 :code
    remove_index :languages,                 :name
    remove_index :partners,                  :partner_tracking_code
    remove_index :publisher_billing_configs, :publisher_type_id
    remove_index :publisher_facebooks,       :token
    remove_index :publisher_facebooks,       :uid
    remove_index :publisher_types,           :name
    remove_index :users,                     :email
    add_index :users,                        :email,             :unique => false
    remove_index :users,                     :perishable_token
    remove_index :users,                     :persistence_token
    add_index :users,                        :persistence_token, :unique => false
  end
end
