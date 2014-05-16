require 'spec_helper'

describe Campaign do
  before(:each) do
    UrlExistanceValidator.any_instance.stub(:validate).with(any_args)
  end
  describe "statuses' behavior" do
    it "should not allow create campaigns with start_date in the past" do
      campaign = Campaign.new(:name => "name",
                              :description => "description",
                              :advertiser => Factory(:advertiser),
                              :start_date => Time.now - 1.day,
                              :end_date => Time.now + 2.days,
                              :click_value => 0.25)
      campaign.save.should be_false
    end

    it "should not allow create campaigns with start_date is after end_date" do
      campaign = Campaign.new(:name => "name",
                              :description => "description",
                              :advertiser => Factory(:advertiser),
                              :start_date => Time.now + 3.days,
                              :end_date => Time.now + 2.days,
                              :click_value => 0.25)
      campaign.save.should be_false
    end
  end

  describe "named scopes" do
    it "should return the scheduled campaigns" do
      Campaign.delete_all
      scheduled = Factory :scheduled_campaign
      active = Factory :active_campaign
      finished = Factory :finished_campaign
      Campaign.scheduled.should eq([scheduled])
    end

    it "should return the active campaigns" do
      Campaign.delete_all    
      scheduled = Factory :scheduled_campaign
      active = Factory :active_campaign
      finished = Factory :finished_campaign
      Campaign.active.should eq([active])
    end
    
    it "should return the finished campaigns" do
      Campaign.delete_all    
      scheduled = Factory :scheduled_campaign
      active = Factory :active_campaign
      finished = Factory :finished_campaign
      Campaign.finished_by_date.should eq([finished])
    end
  end

  describe "publishers" do
    it "should return all publishers" do
      advertiser = Factory(:advertiser)
      place = Factory(:place)
      # Campaign 1
      campaign1 = Factory(:active_campaign, :advertiser => advertiser)
      ad1 = Factory(:ad, :campaign => campaign1)
      post1 = Factory :post, :ad => ad1, :place => place
      # Campaign 2
      campaign2 = Factory(:active_campaign, :advertiser => advertiser)
      ad2 = Factory(:ad, :campaign => campaign2)
      post2 = Factory :post, :ad => ad2, :place => place
      # Publishers per campaign
      campaign1.publishers.should eq([post1.publisher])
      campaign2.publishers.should eq([post2.publisher])
    end
  end

  describe "tracking_requests" do
    it "should return all tracking_requests" do
      advertiser = Factory(:advertiser)
      # Campaign 1
      campaign1 = Factory(:active_campaign, :advertiser => advertiser)
      ad1 = Factory(:ad, :campaign => campaign1)
      post1 = Factory :post, :ad => ad1, :target_url => "http://google.com/1"
      # Campaign 2
      campaign2 = Factory(:active_campaign, :advertiser => advertiser)
      ad2 = Factory(:ad, :campaign => campaign2)
      post2 = Factory :post, :ad => ad2, :target_url => "http://google.com/2"
      # Tracking Request 1
      tracking_request1 = Factory(:tracking_request, :post => post1)
      # Tracking Request 2
      tracking_request2 = Factory(:tracking_request, :post => post2)
      # Publishers per campaign
      campaign1.tracking_requests[0].post.should eq(post1)
      campaign2.tracking_requests[0].post.should eq(post2)
    end

    it "should count only unique publishers" do
      tracking_request1 = Factory(:tracking_request)
      campaign = tracking_request1.post.ad.campaign
      post = tracking_request1.post
      campaign.publishers_count.should eq 1
      Factory :post,
              :place => post.place,
              :ad => Factory(:ad, :campaign => campaign)
      campaign.reload
      campaign.publishers_count.should eq 1
      post3 = Factory :post,
              :ad => Factory(:ad, :campaign => campaign)
      post3.place.publisher.should_not eql(post.place.publisher)
      campaign.reload
      campaign.publishers_count.should eq 2
    end
  end

  describe "click through" do
    it "should be DEFAULT with no post" do
      active_campaign = Factory(:active_campaign)
      active_campaign.click_through.should == Campaign::DEFAULT_CLICK_THROUGH
    end

    it "should be clicks / post" do
      campaign = Factory(:active_campaign)

      ad = Factory :ad, :campaign => campaign
      post = Factory :post, :ad => ad

      campaign.click_through.should == 0
    end
  end

  describe "rating" do
    it "should be equals click_value if there is no posts" do
      campaign = Factory(:active_campaign)
      campaign.rating.should == campaign.click_value
    end
  end
  
  describe "update" do
    it "should update ads' start_date and end_date" do
      campaign = Factory(:active_campaign)
      ad = Factory(:ad, :campaign => campaign)
      ad.start_date = campaign.start_date + 2.day
      ad.end_date = campaign.end_date - 2.day
      ad.save!
      campaign.start_date += 2.day
      campaign.end_date -= 2.day
      campaign.save!
      updated_ad = Ad.find(ad.id)
      
      updated_ad.start_date.should eq campaign.start_date
      updated_ad.end_date.should eq campaign.end_date
    end
    
    it "should update ads' end_date if end_date is after ads' end_date" do
      campaign = Factory(:active_campaign)
      ad = Factory(:ad, :campaign => campaign)
      ad.start_date = campaign.start_date + 2.day
      ad.end_date = campaign.end_date - 2.day
      ad.save!
      campaign.start_date += 1.day
      campaign.end_date -= 1.day
      campaign.save!
      
      updated_ad = Ad.find(ad.id)
      updated_ad.start_date.should eq ad.start_date
      updated_ad.end_date.should eq ad.end_date
    end
    
  end
  
end
