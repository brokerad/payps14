require 'spec_helper'

describe UserSession do
  it "should login with valid user" do
    activate_authlogic
    user = Factory(:user, :password => "testtest", :password_confirmation => "testtest")
    user_session = UserSession.new(:email => user.email, :password => "testtest")
    user_session.save.should be_true
  end

  it "should not login with invalid password" do
    activate_authlogic
    user_session = UserSession.new(:email => "not_found@slytrade.com", :password => "wrong_password")
    user_session.save.should be_false
  end

  it "should login with enabled user" do
    activate_authlogic
    user = Factory(:user, :password => "testtest", :password_confirmation => "testtest", :enabled => true)
    user_session = UserSession.new(:email => user.email, :password => "testtest")
    user_session.save.should be_true
  end

  it "should not login with disabled user" do
    activate_authlogic
    user = Factory(:user, :password => "testtest", :password_confirmation => "testtest", :enabled => false)
    user_session = UserSession.new(:email => user.email, :password => "testtest")
    #user_session.save.should be_false
  end
end
