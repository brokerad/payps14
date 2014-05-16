require "authlogic/test_case"
include Authlogic::TestCase

module ControllerMacros

  def login_admin
    before(:each) do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create(@user)
    end
  end

  def login_advertiser
    before(:each) do
      activate_authlogic
      @advertiser = Factory(:advertiser)
      @user = @advertiser.user
      UserSession.create(@user)
    end
  end

  def login_publisher
    before(:each) do
      activate_authlogic
      @publisher = Factory(:publisher)
      @user = @publisher.user
      @publisher_facebook = Factory(:publisher_facebook, :publisher => @publisher)
      session[:publisher_facebook_id] = @publisher_facebook.id
      UserSession.create(@user)
    end
  end

end
