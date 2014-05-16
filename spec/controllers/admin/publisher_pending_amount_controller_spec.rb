require 'spec_helper'

describe Admin::PublisherPendingAmountController do
  login_admin
  
  describe 'GET index' do
    
    it 'should render index template' do
      get :index
      assigns(:publishers).should be_empty
      response.should be_success
      response.should render_template('index')
    end
    
    it 'should return publihser that have posts' do
      Factory.create(:post)
      Factory.create(:publisher)
      get :index
      assigns(:publishers).count.should eq 1
      Publisher.count.should eq 2
    end
    
  end
  
  describe 'GET search' do
    
    it 'should render index template' do
      get :search
      assigns(:publishers).should be_empty
      response.should be_success
      response.should render_template('index')
    end
    
    it 'should return publihser that have posts and specified in search criteria' do
      post = Factory.create(:post)
      Factory.create(:post)
      Factory.create(:publisher)
      get :search, :search => post.place.publisher_facebook.publisher.email.split('@')[0]
      assigns(:publishers).count.should eq 1
      Publisher.count.should eq 3
    end
    
  end

end
