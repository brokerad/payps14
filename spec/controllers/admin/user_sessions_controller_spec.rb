require "spec_helper"

describe Admin::UserSessionsController do

  render_views

  describe "Login" do
    it "should login" do
      user = login_as_admin
      response.should redirect_to(admin_root_path)
      UserSession.find.record.should eq(user)
    end

    it "should redirect to new session with invalid parameters" do
      post :create, :user_session => {}
      response.should render_template("new")
      UserSession.find.should be_nil
    end
  end

  describe "Logoff" do
    it "should logoff" do
      user = login_as_admin
      delete :destroy, :id => user.id
      response.should redirect_to(new_admin_user_session_path)
      UserSession.find.should be_nil
    end
  end

  def login_as_admin
    user = Factory(:user)
    post :create, :user_session => {:email => user.email, :password => user.password}
    user
  end
end
