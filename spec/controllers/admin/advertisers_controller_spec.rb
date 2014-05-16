require 'spec_helper'

describe Admin::AdvertisersController do
  login_admin

  describe "PUT update" do
    describe "change status" do
      it "should disable the advertiser" do
        user = Factory(:user, :enabled => true)
        advertiser = Factory(:advertiser, :user_id => user.id)
        put :update, :id => advertiser.id, :advertiser => {:user_attributes => {:id => user.id, :enabled => false}, :new_password => ""}
        advertiser.user.reload
        advertiser.user.enabled.should be_false
        response.should redirect_to(admin_advertisers_path)
      end

      it "should enable the advertiser" do
        user = Factory(:user, :enabled => false)
        advertiser = Factory(:advertiser, :user_id => user.id)
        put :update, :id => advertiser.id, :advertiser => {:user_attributes => {:id => user.id, :enabled => true}, :new_password => ""}
        advertiser.user.reload
        advertiser.user.enabled.should be_true
        response.should redirect_to(admin_advertisers_path)
      end
    end
  end
  
  describe "login as advertiser" do
    it "with success" do
      advertiser = Factory(:advertiser)
      get :login_as_advertiser, :advertiser_id => advertiser.id
      response.should redirect_to advertiser_root_path
      request.flash[:success].should eq I18n.t("login.successful")
    end
    it "without success" do
      advertiser = Factory(:advertiser_disabled)
      get :login_as_advertiser, :advertiser_id => advertiser.id
      response.should render_template :index
      assigns(:advertisers).count.should eq Advertiser.all.count
      request.flash[:error].should eq I18n.t("login.failed")
    end
  end
  
  describe "delete advertiser" do
    it "should remove advertiser if account has admin role too" do
      advertiser = Factory(:advertiser)
      User.any_instance.stub(:role).and_return("#{User::ADMIN}|#{User::ADVERTISER}")
      expect { put :remove_advertiser, :advertiser_id => advertiser.id }.to change(Advertiser, :count).by(-1)
      request.flash[:success].should eq I18n.t("advertiser.destroy.success")
    end

    it "should not remove user if advertiser has admin role too" do
      advertiser = Factory(:advertiser)
      User.any_instance.stub(:role).and_return("#{User::ADMIN}|#{User::ADVERTISER}")
      expect { put :remove_advertiser, :advertiser_id => advertiser.id }.to_not change(User, :count)
      request.flash[:success].should eq I18n.t("advertiser.destroy.success")
    end
        
    it "should destroy advertiser if advertiser has no history" do
      advertiser = Factory(:advertiser)
      expect { put :remove_advertiser, :advertiser_id => advertiser.id }.to change(Advertiser, :count).by(-1)
      request.flash[:success].should eq I18n.t("advertiser.destroy.success")
    end
    
    it "should destroy user if advertiser has no history" do
      advertiser = Factory(:advertiser)
      expect { put :remove_advertiser, :advertiser_id => advertiser.id }.to change(User, :count).by(-1)
      request.flash[:success].should eq I18n.t("advertiser.destroy.success")
    end
    
    it "should NOT destory advertiser if advertiser has history" do
      campaign = Factory(:active_campaign)
      expect { put :remove_advertiser, :advertiser_id => campaign.advertiser.id }.to_not change(Advertiser, :count)
      request.flash[:error].should eq I18n.t("advertiser.destroy.with_campaigns")
    end
    
    it "should NOT destory user if advertiser has history" do
      campaign = Factory(:active_campaign)
      expect { put :remove_advertiser, :advertiser_id => campaign.advertiser.id }.to_not change(User, :count)
      request.flash[:error].should eq I18n.t("advertiser.destroy.with_campaigns")
    end
  end
    
  
end
