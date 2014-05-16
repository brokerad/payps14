class PublishersTableUpdateParnerIdColumn < ActiveRecord::Migration
  def self.up
    Publisher.where(:accepted_term_id => 0).update_all(:accepted_term_id => 1)
  end

  def self.down
    #noop
  end
end
