require 'spec_helper'

describe Admin::AdsReportsController do
  render_views

  login_admin

  describe "GET index" do
    it "assigns all ads as @ads" do
      Ad.delete_all
      ad = Factory(:ad)
      get :index
      assigns(:ads).should eq([ad])
    end
  end

end
