require 'spec_helper'

describe Publisher::AdsSearchController do

  def login_publisher
    login_facebook
    login_user
  end

  def login_facebook
    publisher_facebook = Factory(:publisher_facebook)
    session[:publisher_facebook_id] = publisher_facebook.id
  end

  def current_facebook_user
    PublisherFacebook.find(session[:publisher_facebook_id])
  end

  def login_user
    activate_authlogic
    UserSession.create(current_facebook_user.publisher.user)
  end

#   describe "filter and search" do
#     it "execute the search" do
#       login_publisher
#
#       get :index, :keywords => 'pippo'
#       response.should be_success
#     end
#   end

end
