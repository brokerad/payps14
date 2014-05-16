require 'spec_helper'

def validate_facebook_referer(request, http_headers, status)
  UrlExistanceValidator.any_instance.stub(:validate).with(any_args)
  post = Factory(:post)
  campaign = post.ad.campaign
  request.should_receive(:env).and_return(http_headers)
  TrackingRequestAnalyser.status(request, Time.now, post).should eq status
  campaign.status.should eq Campaign::ACTIVE
end

describe TrackingRequestAnalyser do
  
  describe 'status method' do
    before(:each) do
      session = double('session')
      @request = double('request')
      
      @request.stub(:session).and_return(session)
      @request.stub(:ip).and_return('1.1.1.1')
      session.stub(:[]).with(:session_id).and_return('abc123')
    end
    
    describe 'facebook referer' do
  
      it 'should detect facebook referer as empty' do
        http_headers = { "HTTP_REFERER" => 'referer' }
        validate_facebook_referer(@request, http_headers, TrackingRequest::SKIPPED_BY_INVALID_REFERER)
      end
  
      it 'should detect facebook referer as empty, but invalid facebook referer' do
        http_headers = { "HTTP_REFERER" => 'http://xxfacebook.com.com?somepara=value&nextparam=value2' }
        validate_facebook_referer(@request, http_headers, TrackingRequest::SKIPPED_BY_INVALID_REFERER)
      end
      
    end
    
    it 'should detect finished by budget campaigns clicks' do
      UrlExistanceValidator.any_instance.stub(:validate).with(any_args)
      post = Factory(:post_with_finished_by_budget_campaign)
      campaign = post.ad.campaign
      http_headers = { 
        "HTTP_USER_AGENT" => 'agent', 
        "HTTP_REFERER" => 'http://facebook.com?somepara=value&nextparam=value2' }
        
      @request.should_receive(:env).and_return(http_headers)
      TrackingRequestAnalyser.status(@request, Time.now, post).should eq TrackingRequest::SKIPPED_BY_BUDGET
      campaign.status.should eq Campaign::FINISHED_BY_BUDGET
    end
    
  end
  
end
