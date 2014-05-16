require "spec_helper"


def iit(attribute, &block)
  it(attribute, &block)
end

describe User do

  describe "Facebook" do
    iit "should create a user from Facebook" do
      publisher_facebook = Factory(:publisher_facebook)
      user = User.create_from_facebook(publisher_facebook)
      user.persisted?.should be_true
      user.email.should eq publisher_facebook.publisher.user.email
      user.enabled.should be_true
      user.role.should eq(User::PUBLISHER)
    end
  end

  describe "Role" do
    iit "should not in role 'admin'" do
      user = Factory(:user, :role => User::PUBLISHER)
      user.role?(User::ADMIN).should be_false
    end

    iit "should in role 'admin'" do
      user = Factory(:user, :role => User::ADMIN)
      user.role?(User::ADMIN).should be_true
    end

    it "should add two roles" do
      user = Factory(:user, :role => User::ADMIN)
      user.add_role!(User::ADVERTISER)
      user.role?(User::ADMIN).should be_true
      user.role?(User::ADVERTISER).should be_true
    end

    iit "should not duplicate role" do
      user = Factory(:user, :role => User::ADMIN)
      user.add_role!(User::ADMIN)
      user.role?(User::ADMIN).should be_true
    end
  end

  iit "should enable an user" do
    user = Factory(:user, :enabled => false)
    user.enabled = true
    user.save
    user.enabled?.should be_true
  end

  iit "should disable an user" do
    user = Factory(:user, :enabled => true)
    user.enabled = false
    user.save
    user.reload
    user.enabled?.should be_false
  end

  describe "Email validations" do
    iit "should allow valid email" do
      user = Factory(:user)
      user.email = "test@slytrade.com"
      user.valid?.should be_true
    end

    iit "should not allow invalid email" do
      user = Factory(:user)
      user.email = "test"
      user.valid?.should be_false
    end
  end
end
