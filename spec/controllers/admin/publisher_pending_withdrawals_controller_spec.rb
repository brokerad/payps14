require 'spec_helper'

describe Admin::PublisherPendingWithdrawalsController do
  login_admin
  
  describe 'Get transactions' do
    
    it 'should render transactions template' do
      Publisher.should_receive(:find).and_return(double('publisher'))
      BillingService.should_receive(:new).and_return(billing_service = double('billing_service'))
      billing_service.should_receive(:publisher_checking_account).and_return(double('account'))
      get :transactions, :id => 1
      response.should be_success
      response.should render_template('transactions')
    end
    
    it 'should assign correct instance variables' do
      publisher = Factory(:publisher)
      account = Factory(:account)
      BillingService.should_receive(:new).and_return(billing_service = double('billing_service'))
      billing_service.should_receive(:publisher_checking_account).and_return(account)
      get :transactions, :id => publisher
      assigns(:account).should eq account
      assigns(:publisher).should eq publisher
    end
    
  end

end

