require "spec_helper"

describe TrackingCodesController do
  describe "redirect" do
    it "should redirect to target url" do
      tracking_code = Factory(:tracking_code)
      tracking_code.count.should eq 0
      get "show", :tracking_code => tracking_code.code
      tracking_code.reload
      tracking_code.count.should eq 1
      response.code.should eq "302"
      response.should redirect_to(tracking_code.target_url)
    end
  end
end
