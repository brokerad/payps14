require 'spec_helper'

describe Admin::CouponsController do
  render_views
  login_admin

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "Create new coupon" do
    it "return success" do
      coupon = Factory(:coupon)
      coupon.should be_persisted
    end

    it "Return error" do
       Factory.build(:coupon, :name => "").should_not be_valid
     end
  end

  describe "Check coupon" do
    it "should return INVALID status" do
      coupon = Factory.build(:coupon)
      Coupon.status(nil).should == -1
    end
    it "should return NONACTIVE status" do
      coupon = Factory.build(:coupon, :start_date => Date.today + 3.days)
      Coupon.status(coupon).should == -2
    end
    it "should return EXPIRED status" do
      coupon = Factory.build(:coupon, :end_date => Date.today - 3.days)
      Coupon.status(coupon).should == -3
    end
    it "should return VALID status" do
      coupon = Factory.build(:coupon)
      Coupon.status(coupon).should == 1
    end
  end

end
