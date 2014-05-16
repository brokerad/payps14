require 'spec_helper'

describe Publisher::RegisterFacebookController do
  
  context 'fail action' do
    
    it 'should display fb message' do
      get :fail, { :message => 'failed fb msg' }
      flash[:error].should =~ /failed fb msg/i
    end
    
    it 'should redirect to default login page' do
      get :fail
      response.should redirect_to publisher_publisher_login_path
    end
    
  end
  
end
