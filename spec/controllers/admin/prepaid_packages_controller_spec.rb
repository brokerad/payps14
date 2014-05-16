require "spec_helper"

describe Admin::PrepaidPackagesController do
  render_views

  login_admin

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end
end
