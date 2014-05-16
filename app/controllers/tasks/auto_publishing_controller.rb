class Tasks::AutoPublishingController < ActionController::Base
  def index
    Post.auto_publish
    render :text => "done"
  end
end
