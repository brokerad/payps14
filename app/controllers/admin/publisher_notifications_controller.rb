class Admin::PublisherNotificationsController < Admin::ApplicationController
  def index
    @notifications = PublisherNotification.order('created_at DESC')
  end

  def new
    @notification = PublisherNotification.new
  end

  def create    
    @notification = PublisherNotification.new(params[:publisher_notification])
    if @notification.save
      redirect_to(admin_publisher_notifications_path, :notice => 'Notification was successfully sent.')
    else
      render :action => "new"    
    end
  end
end
