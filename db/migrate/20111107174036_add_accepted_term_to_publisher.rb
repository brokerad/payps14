class AddAcceptedTermToPublisher < ActiveRecord::Migration
  def self.up
    add_column :publishers, :accepted_term_id, :integer
  end

  def self.down
    remove_column :publishers, :accepted_term_id
  end
end
