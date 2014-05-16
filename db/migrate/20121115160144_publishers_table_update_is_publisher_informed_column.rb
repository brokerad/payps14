class PublishersTableUpdateIsPublisherInformedColumn < ActiveRecord::Migration
  def self.up
    Publisher.where('partner_id is not null and accepted_term_id is not null').update_all(:is_partner_informed => true)
  end

  def self.down
    #noop
  end
end
