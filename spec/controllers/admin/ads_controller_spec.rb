require "spec_helper"

describe Admin::AdsController do
  render_views

  login_admin

  def valid_attributes
    attributes = Factory.attributes_for(:ad)
    advertiser = Factory(:advertiser)
    attributes[:campaign] = Factory(:active_campaign, :advertiser => advertiser)
    attributes[:categories][0] = Factory(:category)
    attributes
  end

  describe "GET index" do
    it "assigns all ads as @ads" do
      Ad.delete_all
      ad = Factory(:ad)
      get :index
      assigns(:ads).should eq([ad])
    end
  end

  describe "GET new" do
    it "assigns a new ad as @ad" do
      get :new
      assigns(:ad).should be_a_new(Ad)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Ad" do
        expect {
          post :create, :ad => valid_attributes
        }.to change(Ad, :count).by(1)
      end

      it "assigns a newly created ad as @ad" do
        post :create, :ad => valid_attributes
        assigns(:ad).should be_a(Ad)
        assigns(:ad).should be_persisted
      end

      it "redirects to the created ad" do
        post :create, :ad => valid_attributes
        response.should redirect_to(admin_ads_path)
      end
      
      it "should override message with default one: '.'(dot)" do
        post :create, :ad => valid_attributes
        assigns(:ad).message.should eq '.'
      end
      
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved ad as @ad" do
        # Trigger the behavior that occurs when invalid params are submitted
        Ad.any_instance.stub(:save).and_return(false)
        post :create, :ad => {}
        assigns(:ad).should be_a_new(Ad)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Ad.any_instance.stub(:save).and_return(false)
        post :create, :ad => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested ad" do
        ad = Ad.create! valid_attributes
        # Assuming there are no other users in the database, this
        # specifies that the User created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Ad.any_instance.should_receive(:attributes=).with({'these' => 'params'})
        put :update, :id => ad.id, :ad => {'these' => 'params'}
      end

      it "assigns the requested ad as @ad" do
        ad = Ad.create! valid_attributes
        valid_attributes[:message] = 'message'
        put :update, :id => ad.id, :ad => valid_attributes
        assigns(:ad).should eq(ad)
      end

      it "redirects to the ad" do
        ad = Ad.create! valid_attributes
        put :update, :id => ad.id, :ad => valid_attributes
        response.should redirect_to(admin_ads_path)
      end
      
      it "should override message with default one: '.'(dot)" do
        ad = Ad.create! valid_attributes
        put :update, :id => ad.id, :ad => valid_attributes
        assigns(:ad).message.should eq '.'
      end
      
    end

    describe "with invalid params" do
      it "assigns the ad as @ad" do
        ad = Ad.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Ad.any_instance.stub(:save).and_return(false)
        put :update, :id => ad.id.to_s, :ad => {}
        assigns(:ad).should eq(ad)
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested ad" do
      advertiser = Factory(:advertiser)
      campaign = Factory(:active_campaign, :advertiser => advertiser)
      ad = Factory(:ad, :campaign => campaign)
      expect {
        delete :destroy, :id => ad.id.to_s
      }.to change(Ad, :count).by(-1)
    end

    it "redirects to the ads list" do
      advertiser = Factory(:advertiser)
      campaign = Factory(:active_campaign, :advertiser => advertiser)
      ad = Factory(:ad, :campaign => campaign)
      delete :destroy, :id => ad.id.to_s
      response.should redirect_to(admin_ads_path)
    end
  end
end
