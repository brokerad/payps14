require 'spec_helper'

describe Advertiser do
  describe "Creation rules" do
    it "should CHANGE the user role to User::ADVERTISER when create an advertiser" do
      user = Factory(:user, :role => User::PUBLISHER)
      adv = Factory(:advertiser_without_user, :user => user)
      adv.user.role?(User::ADVERTISER).should be_true
    end

    it "should KEEP the user role when create an advertiser" do
      user = Factory(:user, :role => User::ADVERTISER)
      adv = Factory(:advertiser_without_user, :user => user)
      adv.user.role?(User::ADVERTISER).should be_true
    end
  end

  describe "site validation" do
    it "should allow correct url in site" do
      advertiser = Factory(:advertiser)
      advertiser.site = "http://google.com"
      advertiser.valid?.should be_true
    end

    it "should not allow invalid value in site" do
      advertiser = Factory(:advertiser)
      advertiser.site = "invalid_url"
      advertiser.valid?.should be_false
    end
    
    it 'has_history should return true is he has any campaigns' do
      advertiser = Factory(:advertiser)
      Factory(:finished_campaign, :advertiser => advertiser)
      advertiser.has_history.should be_true
    end
    
    it 'has_history should return fals is he has no campaigns' do
      advertiser = Factory(:advertiser)
      advertiser.has_history.should be_false
    end

    it 'should delete itself when destroy is called' do
      advertiser = Factory(:advertiser)
      expect { advertiser.destroy }.to change(Advertiser, :count).by(-1)
    end
        
    it 'should delete his user model when destroy is called' do
      advertiser = Factory(:advertiser)
      expect { advertiser.destroy }.to change(User, :count).by(-1)
    end
    
    
  end
end
