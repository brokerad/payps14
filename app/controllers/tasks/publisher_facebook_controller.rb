class Tasks::PublisherFacebookController < ActionController::Base

  def update_friends_count
    #TODO: check out why it was used, because it will take a lot of time to updatea all places.
    # PublisherFacebook.update_friends_count_all
    render :text => "done"
  end
end