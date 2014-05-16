require "spec_helper"

describe Admin::CampaignsController do
  login_admin

  describe "GET index" do
    it "it should render with success" do
      get :index
      response.should be_success
    end
    
    it "it should read all enabled advertisers" do
      Factory(:advertiser_disabled)
      get :index
      #NOTE: there are 2 not 1 because we add one new advertiser to emulate 'ALL' keyword 
      assigns(:available_advertisers).count.should eq 2
      Advertiser.count.should eq 2
    end
    
    it "it should read advertiser's campaigns" do
      campaign = Factory(:active_campaign)

      get :index, {:advertiser => campaign.advertiser.id}
      assigns(:selected_advertiser).should eq campaign.advertiser.id
      assigns(:campaigns)[0].should eq campaign
      Advertiser.count.should eq 2
    end
    
    it "it should read all campaigns when advertiser is not provided" do
      get :index
      
      assigns(:selected_advertiser).should be_blank
      assigns(:campaigns).count.should eq 1
    end
    
  end
  
  describe 'GET new' do
    it 'should display new action' do
      get :new
      response.should be_success
      response.should render_template(:new)
    end
    
    it 'should assigns a new campaign as @campaign' do
      get :new
      assigns(:campaign).should be_a_new(Campaign)
    end
    
    it 'should assigns a all markets as @market' do
      get :new
      assigns(:markets).should eq Market.all.collect {|m| [m.name, m.id]}
    end
  end
  
  
  describe 'POST create' do
    it 'should check if compaign with same name already exists' do
      campaign = Factory(:active_campaign)
      campaign_to_save_attr = Factory.attributes_for(:active_campaign, :name => campaign.name)
      post :create, {:campaign => campaign_to_save_attr}
      assigns(:campaign).errors[:name].should eq ['has already been taken']
      response.should render_template(:new)
    end
  end
  
  describe 'POST update' do
    it 'should permit to update any field for scheduled campaings' do
      campaign = Factory(:scheduled_campaign)
      CampaignService.should_receive(:update).with(campaign, campaign.budget).and_return(true)
      post :update, {:id => campaign.id, 
        :campaign => {:budget => 39.91, :name => 'new_name^7', :click_value => 3.21}}
      response.should redirect_to admin_campaigns_path
      flash[:notice].should eq I18n.t("campaign.updated.success")
    end

    it 'should fail to update scheduled campaings' do
      campaign = Factory(:scheduled_campaign)
      CampaignService.should_receive(:update).with(campaign, campaign.budget).and_return(false)
      post :update, {:id => campaign.id, 
        :campaign => {:budget => 39.91, :name => 'new_name^7', :click_value => 3.21}}
      response.should be_success
      response.should render_template(:edit)
      assigns(:campaign).should be_true
      assigns(:editable_end_date).should be_true
      assigns(:advertisers).should_not be_nil
      assigns(:markets).should_not be_nil
    end

    it 'should permint to update end_date and status for active and paused campaings' do
      pending
    end
    it 'should not permit to update any fields for active and paused campaings except end_date and status' do
      pending
    end
    it 'should not permit to update any fields for campaings with any status except scheduled, active and paused' do
      pending
    end
  end
end
