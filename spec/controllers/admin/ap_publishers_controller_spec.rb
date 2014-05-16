require 'spec_helper'

describe Admin::ApPublishersController do
  login_admin

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

end
