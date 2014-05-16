require 'spec_helper'

describe Admin::TrackingUrlsController do
login_admin

  def get_partner
    @partner ||= Factory(:partner)
  end
  
  def valid_attributes
    rand_nr = rand(Time.now.utc.to_i)
    { :name => "Tracking url - #{rand_nr}", 
      :lead_url => "lead-url-#{rand_nr}",
      :tracking_code => "tr-code-123-#{rand_nr}",
      :active => true,
      :partner_id => get_partner.id }
  end
  
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all tracking_urls as @tracking_urls" do
      tracking_url = TrackingUrl.create! valid_attributes
      get :index
      assigns(:tracking_urls).should eq([tracking_url])
    end
  end

  describe "GET show" do
    it "assigns the requested tracking_url as @tracking_url" do
      tracking_url = TrackingUrl.create! valid_attributes
      get :show, {:id => tracking_url.to_param}
      assigns(:tracking_url).should eq(tracking_url)
    end
  end

  describe "GET new" do
    it "assigns a new tracking_url as @tracking_url" do
      get :new
      assigns(:tracking_url).should be_a_new(TrackingUrl)
    end
  end

  describe "GET edit" do
    it "assigns the requested tracking_url as @tracking_url" do
      tracking_url = TrackingUrl.create! valid_attributes
      get :edit, {:id => tracking_url.to_param}
      assigns(:tracking_url).should eq(tracking_url)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TrackingUrl" do
        expect {
          post :create, {:tracking_url => valid_attributes}
        }.to change(TrackingUrl, :count).by(1)
      end

      it "assigns a newly created tracking_url as @tracking_url" do
        post :create, {:tracking_url => valid_attributes}
        assigns(:tracking_url).should be_a(TrackingUrl)
        assigns(:tracking_url).should be_persisted
      end

      it "redirects to the created tracking_url" do
        post :create, {:tracking_url => valid_attributes}
        response.should redirect_to(admin_tracking_urls_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved tracking_url as @tracking_url" do
        # Trigger the behavior that occurs when invalid params are submitted
        TrackingUrl.any_instance.stub(:save).and_return(false)
        post :create, {:tracking_url => {}}
        assigns(:tracking_url).should be_a_new(TrackingUrl)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        TrackingUrl.any_instance.stub(:save).and_return(false)
        post :create, {:tracking_url => {}}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested tracking_url" do
        tracking_url = TrackingUrl.create! valid_attributes
        # Assuming there are no other tracking_urls in the database, this
        # specifies that the TrackingUrl created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        TrackingUrl.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => tracking_url.to_param, :tracking_url => {'these' => 'params'}}
      end

      it "assigns the requested tracking_url as @tracking_url" do
        tracking_url = TrackingUrl.create! valid_attributes
        put :update, {:id => tracking_url.to_param, :tracking_url => valid_attributes}
        assigns(:tracking_url).should eq(tracking_url)
      end

      it "redirects to the tracking_url" do
        tracking_url = TrackingUrl.create! valid_attributes
        put :update, {:id => tracking_url.to_param, :tracking_url => valid_attributes}
        response.should redirect_to(admin_tracking_urls_path)
      end
    end

    describe "with invalid params" do
      it "assigns the tracking_url as @tracking_url" do
        tracking_url = TrackingUrl.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        TrackingUrl.any_instance.stub(:save).and_return(false)
        put :update, {:id => tracking_url.to_param, :tracking_url => {}}
        assigns(:tracking_url).id.should eq(tracking_url.id)
        assigns(:tracking_url).name.should be_nil
      end

      it "re-renders the 'edit' template" do
        tracking_url = TrackingUrl.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        TrackingUrl.any_instance.stub(:save).and_return(false)
        put :update, {:id => tracking_url.to_param, :tracking_url => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested tracking_url" do
      tracking_url = Factory(:tracking_url)
      expect {
        delete :destroy, {:id => tracking_url.to_param}
      }.to change(TrackingUrl, :count).by(-1)
    end

    it "redirects to the tracking_urls list" do
      tracking_url = Factory(:tracking_url)
      delete :destroy, {:id => tracking_url.to_param}
      response.should redirect_to(admin_tracking_urls_path)
    end
  end

end
