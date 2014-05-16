require 'spec_helper'

describe PrepaidPackage do
  describe "Calculate the discount" do
    it "should calculate the discount" do
      prepaid_package = PrepaidPackage.new(:package_code => "Package 100", :discount => 10, :price => 100, :start_date => Time.now + 1, :end_date => Time.now + 2)
      prepaid_package.save
      prepaid_package.budget.to_i.should == 110
    end

    it "should calculate the nominal discount" do
      prepaid_package = PrepaidPackage.new(:package_code => "Package 100", :discount => 10, :price => 500, :start_date => Time.now + 1, :end_date => Time.now + 2)
      prepaid_package.save
      prepaid_package.discount?.should be_true
      prepaid_package.nominal_discount.should == 50
    end
  end
end
