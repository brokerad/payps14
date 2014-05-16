class PublishersTableAddMissedIndexes < ActiveRecord::Migration
  def self.up
    add_index :publishers, :email
    add_index :publishers, :user_id
    add_index :publishers, :publisher_type_id
    add_index :publishers, :partner_id
    add_index :publishers, :accepted_term_id
    add_index :publishers, :language_id
    add_index :publishers, :coupon_id
  end

  def self.down
    remove_index :publishers, :email
    remove_index :publishers, :user_id
    remove_index :publishers, :publisher_type_id
    remove_index :publishers, :partner_id
    remove_index :publishers, :accepted_term_id
    remove_index :publishers, :language_id
    remove_index :publishers, :coupon_id
  end
end
