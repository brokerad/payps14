require 'spec_helper'

describe Publisher do

  it "should return the name" do
    publisher = Publisher.new(:first_name => "Pablo", :last_name => "Cantero")
    publisher.name.should eq("Pablo Cantero")
    publisher.last_name = nil
    publisher.name.should eq("Pablo")
    publisher.first_name = nil
    publisher.last_name = "Cantero"
    publisher.name.should eq("Cantero")
  end

  describe "mandatory data" do
    it "should return false" do
      publisher = Factory(:publisher, :language => nil, :market => nil)
      publisher.filled_mandatory_data?.should be_false
    end

    it "should return true" do
      publisher = Factory(:publisher)
      publisher.filled_mandatory_data?.should be_true
    end
  end

  it "should validate accepted term" do
    publisher = Factory(:publisher, :accepted_term_id => nil)
    publisher.accepted_term?.should be_false
    term = Factory(:term_enabled)
    publisher.accepted_term = term
    publisher.accepted_term?.should be_true
  end

  describe "Facebook Publisher" do
    it "should create from a facebook publisher" do
      publisher_facebook = Factory(:publisher_facebook, :publisher => nil)
      publisher = Factory(:publisher)
      publisher.set_facebook_attributes!(publisher_facebook)
      publisher.reload
      publisher_facebook.reload
      publisher_facebook.publisher.should eq(publisher)
      publisher.first_name.should eq(publisher_facebook.first_name)
      publisher.last_name.should eq(publisher_facebook.last_name)
      publisher.email.should eq(publisher_facebook.email)
      publisher.publisher_facebooks.should eq([publisher_facebook])
    end
  end

  describe "Automatic places" do
    it "should create a place" do
      publisher_facebook = Factory(:publisher_facebook, :publisher => nil)
      publisher = Factory(:publisher)
      publisher.set_facebook_attributes!(publisher_facebook)
      # TODO mock the request to get the same result for all requests. Take a look at http://rubygems.org/gems/vcr
      # publisher.places.size.should == 0
      # publisher.lookup_places
      # publisher.places.size.should == 1
      # publisher.places[0].place_type.should eq("Account")
      # publisher.places[0].name.should eq("")
      # publisher.places[0].friends.to_s.should eq("1")
      # publisher.places[0].fans.to_s.should eq("0")
    end
  end

  describe "Connections" do
    it "should return an empty connection list" do
      publisher = Factory(:publisher)
      publisher.connections.should eq 0
    end

    it "should return one connection" do
      publisher = Factory(:publisher)
      publisher_facebook = Factory(:publisher_facebook, :publisher => publisher)
      publisher.publisher_facebooks.should eq([publisher_facebook])
    end
  end

  describe "Publish a message" do
    it "should send a message to all connections" do
      publisher = Publisher.new
      ad = Ad.new
      publisher_facebook_1 = mock_model(PublisherFacebook)
      publisher_facebook_2 = mock_model(PublisherFacebook)
      publisher.publisher_facebooks << publisher_facebook_1
      publisher.publisher_facebooks << publisher_facebook_2
      publisher_facebook_1.should_receive(:publish).with(ad, Post::MANUAL, nil, nil).once
      publisher_facebook_2.should_receive(:publish).with(ad, Post::MANUAL, nil, nil).once
      publisher.publish ad
    end
  end

  it "should answer properly accepted the terms" do
    publisher = Publisher.new
    publisher.accepted_term?.should be_false
    publisher.accepted_term = Term.new
    publisher.accepted_term?.should be_true
  end

  describe "Publisher is ready for billing" do
    it "should pass if paypal is filled" do
      publisher = Factory :publisher, :paypal => nil
      publisher.ready_for_billing?.should be_false

      publisher = Factory :publisher, :paypal => "value"
      publisher.ready_for_billing?.should be_true
    end
  end

  describe 'partner eligible time interval' do
    before :all do
      @campaign = Factory(:active_campaign)
    end
    
    context 'exists' do
      it 'should return an valid interval' do
        tracking_url = Factory(:tracking_url)
        revenue_share = Factory(:revenue_share, :tracking_url => tracking_url)
        publisher = Factory(:publisher_engaged, :engage_date => Time.now.utc + 5.days, :tracking_url => tracking_url)
        
        publisher.get_eligible_time_interval(@campaign).should be_a Paypersocial::TimeInterval::TimeIntervalHolder
      end
    end
    
    context 'empty' do
      before :each do
        @tracking_url = Factory(:tracking_url)
        revenue_share = Factory(:revenue_share, :tracking_url => @tracking_url)
      end
      
      after :each do
        @publisher.get_eligible_time_interval(@campaign).should be_nil
      end
      
      it 'should return nil because of nil engage_date' do
        @publisher = Factory(:publisher_engaged, :engage_date => nil, :tracking_url => @tracking_url)
      end
  
      it 'should return nil because of nil tracking_url' do
        @publisher = Factory(:publisher_engaged, :engage_date => Time.now.utc + 5.days, :tracking_url => nil)
      end
  
      it 'should return nil because engage_date is outside revenue_share active perioad of time: before' do
        @publisher = Factory(:publisher_engaged, :engage_date => Time.now.utc + 1.days, :tracking_url => @tracking_url)
      end
      
      it 'should return nil because engage_date is outside revenue_share active perioad of time: after' do
        @publisher = Factory(:publisher_engaged, :engage_date => Time.now.utc + 15.days, :tracking_url => @tracking_url)
      end
  
      it 'should return nil because partner condition is inactive' do
        tracking_url = Factory(:tracking_url)
        revenue_share = Factory(:revenue_share, :active => false, :tracking_url => tracking_url)
        @publisher = Factory(:publisher_engaged, :engage_date => Time.now.utc + 5.days, :tracking_url => tracking_url)
      end
    end
  end

  describe 'delegates' do
    context 'coupon' do
      it 'can be read' do
        # tracking_url = Factory(:tracking_url)
        # coupon = Factory(:coupon, :tracking_urls => [tracking_url], :partner => tracking_url.partner)
        # Factory(:publisher, :tracking_url => coupon.tracking_urls[0]).
          # coupon.should be_an_instance_of(Coupon)
      end
      it 'return nil if coupon does not exist' do
        Factory(:publisher).partner.should be_nil
      end
    end
    
    context 'partner' do
      it 'can be read' do
        Factory(:publisher, :tracking_url => Factory(:tracking_url)).
          partner.should be_an_instance_of(Partner)
      end
      it 'return nil if partner does not exist' do
        Factory(:publisher).partner.should be_nil
      end
    end
    
    context 'revenue_share' do
      it 'can be read' do
        tracking_url = Factory(:tracking_url)
        revenue_share = Factory(:revenue_share, :tracking_url => tracking_url)
        
        Factory(:publisher, :tracking_url => revenue_share.tracking_url).
          revenue_share.should be_an_instance_of(RevenueShare)
      end
      it 'return nil if partner does not exist' do
        Factory(:publisher).revenue_share.should be_nil
      end
    end
  end

  describe 'payable clicks for campaing and specific time interval' do
    context 'exits' do
      before(:each) do
        tracking_url = Factory(:tracking_url)
        revenue_share = Factory(:revenue_share, :tracking_url => tracking_url,
          :start_date => Time.now.utc + 1.days, :end_date => Time.now.utc + 11.days, :duration => 10)
        
        @publisher = Factory(:publisher_engaged, :engage_date => Time.now.utc, :tracking_url => tracking_url)
        publisher_fb = Factory(:publisher_facebook_engaged, :publisher => @publisher)
        place = Factory(:place, :publisher_facebook => publisher_fb)
        @post = Factory(:post, :place => place)
        
        Factory(:tracking_request, :created_at => Time.now.utc - 2.days)
      end
      
      it 'should return valid clicks' do
        clicks = generate_3_clicks(@post)
        
        ti = Paypersocial::TimeInterval::TimeIntervalHolder.new(Time.now.utc - 1.days, Time.now.utc + 1.days)
        @publisher.should_receive(:get_eligible_time_interval).with(@post.ad.campaign).and_return(ti)

        @publisher.get_partner_payable_clicks(@post.ad.campaign).should eq clicks.size
      end
      
      it 'should return zero if no clicks found' do
        ti = Paypersocial::TimeInterval::TimeIntervalHolder.new(Time.now.utc - 1.days, Time.now.utc + 1.days)
        @publisher.should_receive(:get_eligible_time_interval).with(@post.ad.campaign).and_return(ti)

        result = @publisher.get_partner_payable_clicks(@post.ad.campaign)
        result.should eq 0
      end
      
      it 'should return zero if time interval is not valid' do
        clicks = generate_3_clicks(@post)
        ti = Paypersocial::TimeInterval::TimeIntervalHolder.new(Time.now.utc - 10.days, Time.now.utc - 5.days)
        @publisher.should_receive(:get_eligible_time_interval).with(@post.ad.campaign).and_return(ti)

        result = @publisher.get_partner_payable_clicks(@post.ad.campaign)
        result.should eq 0
      end
      
      it 'should return zero if partner condition do not exists' do
        clicks = generate_3_clicks(@post)
        ti = Paypersocial::TimeInterval::TimeIntervalHolder.new(Time.now.utc - 10.days, Time.now.utc - 5.days)
        @publisher.should_receive(:get_eligible_time_interval).with(@post.ad.campaign).and_return(ti)

        result = @publisher.get_partner_payable_clicks(@post.ad.campaign)
        result.should eq 0
      end
    end
    
    def build_revenue_share(publisher)
      Factory(:revenue_share, :tracking_url => publisher.tracking_url,
        :start_date => Time.now.utc + 1.days, :end_date => Time.now.utc + 11.days, :duration => 10)
    end
    
    def generate_3_clicks(post)
      [ Factory(:tracking_request, :post => post), 
        Factory(:tracking_request, :post => post),
        Factory(:tracking_request, :post => post)]
    end
  end
  
  describe 'revenue share' do
    context 'coupon' do
      it 'should belong to the same tracking url assigned to publisher' do
        tu = Factory(:tracking_url)
        coupon = Factory(:coupon, :tracking_urls => [tu], :partner => tu.partner)
        Factory(:publisher, :tracking_url => tu, :coupon => coupon).should be_valid
      end
      
      it "should throw exception if tracking url and coupon's tracking url are different" do
        tu_1 = Factory(:tracking_url)
        tu_2 = Factory(:tracking_url, :partner => tu_1.partner)
        coupon = Factory(:coupon, :tracking_urls => [tu_1], :partner => tu_1.partner)
        expect { Factory(:publisher, :tracking_url => tu_2, :coupon => coupon).should be_valid }.to raise_error
      end
      
      it 'should throw exception if tracking url is not present' do
        tu = Factory(:tracking_url)
        coupon = Factory(:coupon, :tracking_urls => [tu], :partner => tu.partner)
        expect { Factory(:publisher, :coupon => coupon).should be_valid }.to raise_error
      end
    end
  end
  
end
