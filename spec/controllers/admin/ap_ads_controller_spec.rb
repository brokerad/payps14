require 'spec_helper'

describe Admin::ApAdsController do
  login_admin

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

end
