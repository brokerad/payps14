class Tasks::PostsController < ActionController::Base

  def update_posts_count
    Post.update_posts_count_all
    render :text => "done"
  end
end