require 'koala'

class PublisherNotification < ActiveRecord::Base
  FACEBOOK_APP_ACCESS_TOKEN_DEV = "210811618973036|fIbCtKwfpG8eZSo2YIUbO3SKTWU"
  FACEBOOK_APP_ACCESS_TOKEN_QA  = "242262269176125|2kJxQndImmLuFqDI3Z3EJfhJChA"
  FACEBOOK_APP_ACCESS_TOKEN_PRO = "326914134088169|mChwOpcnqpMHGVgQmI2YUvGTlAw"
  MIN_MINUTES_AGO = 10 
  TEST_FB_UID_LIST = [100003195928114] # Giacomo
  
  attr_accessor :uids
  
  validates :notification_text, :title, :presence => true
  validates :notification_text, :length => { :maximum => 180 }
  validates :uids, :presence => true
  validate :notification_must_not_be_bothering
  
  before_create :send_notification
  
  def notification_must_not_be_bothering
    now = Time.now
    last_notification = PublisherNotification.find(:all, :order => 'created_at DESC').first
    if last_notification
      errors.add(:title, "You sent a notification less than #{MIN_MINUTES_AGO} minutes ago") if ((now.utc - last_notification.created_at.utc) < (60 * MIN_MINUTES_AGO))
    end
  end
  
  def send_notification    
    app_access_token = FACEBOOK_APP_ACCESS_TOKEN_PRO  if Rails.env.production?
    app_access_token = FACEBOOK_APP_ACCESS_TOKEN_QA   if Rails.env.qa?
    app_access_token = FACEBOOK_APP_ACCESS_TOKEN_DEV  if Rails.env.development?
    publisher_ids = Array.new
    uids.split(',').each { |id| publisher_ids << id.strip } 
    if Rails.env.development?
      facebook_ids = TEST_FB_UID_LIST 
    else
      facebook_ids = PublisherFacebook.joins(:publisher).where("publishers.id IN (?)", publisher_ids).map(&:uid) 
    end        
    @graph = Koala::Facebook::API.new app_access_token 
    @graph.batch do |batch_api| 
      facebook_ids.each_slice(50) do |uid| 
        @graph.batch do |batch_api| 
          uid.each { |u| batch_api.put_connections(u, "notifications", :template => "#{notification_text}") } 
        end
      end
    end
    self.details = "Notification sent to #{facebook_ids.count} publishers"
  end
end
