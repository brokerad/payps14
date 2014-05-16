require "spec_helper"

def active_ad
	ad = Ad.new(:message => "message",
              :link => "http://google.com",
	            :link_name => "http://google.com",
	            :link_caption => "Google",
              :link_description => "Google homepage",	            
	            :picture_link => "http://google.com/favicon.ico", 
	            :start_date => Time.now,
	            :end_date => Time.now + 2.days,                
	            :campaign => Factory(:active_campaign),
              :visibilityrating => Ad::G,
	            :categories => [Factory(:category)])
end

describe Ad do
  it "should allow correct url" do
    ad = Ad.new(:message => "message",
                :link => "http://google.com",
                :link_name => "http://google.com",
                :link_caption => "Google",
                :link_description => "Google homepage",
                :picture_link => "http://google.com/favicon.ico",
                :visibilityrating => Ad::G,
                :start_date => Time.now + 1.day + 1.hours,
                :end_date => Time.now + 1.day + 10.hours,
                :campaign => Factory(:active_campaign),
                :categories => [Factory(:category)])
    ad.valid?.should be_true
  end

  it "should not allow invalid value in link" do
    ad = Ad.new(:message => "message",
                :link => "wrong_url",
                :link_name => "http://google.com",
                :link_caption => "Google",
                :link_description => "Google homepage",                
                :picture_link => "http://google.com/favicon.ico",
                :start_date => Time.now + 1.day + 1.hours,
                :end_date => Time.now + 1.day + 10.hours,                
                :campaign => Factory(:active_campaign),
                :categories => [Factory(:category)])
    ad.valid?.should be_false
  end

  it "should not allow invalid value in picture_link" do
    ad = Ad.new(:message => "message",
                :link => "http://google.com",
                :link_name => "http://google.com",
                :link_caption => "Google",
                :link_description => "Google homepage",                
                :picture_link => "wrong_picture_link",
                :start_date => Time.now + 1.day + 1.hours,
                :end_date => Time.now + 1.day + 10.hours,                
                :campaign => Factory(:active_campaign),
                :categories => [Factory(:category)])
    ad.valid?.should be_false
  end

  it "should not allow invalid date range" do
  	campaign = Factory :active_campaign
    ad = Ad.new(:message => "message",
                :link => "wrong_url",
                :link_name => "http://google.com",
                :link_caption => "Google",
                :link_description => "Google homepage",                
                :picture_link => "http://google.com/favicon.ico", 
                :start_date => campaign.start_date - 1.days,
                :end_date => campaign.end_date - 3.hours,                
                :campaign => campaign,
                :categories => [Factory(:category)])
    ad.valid?.should be_false
  end
  
  it "should not allow invalid date range" do
  	campaign = Factory(:active_campaign)
    ad = Ad.new(:message => "message",
                :link => "wrong_url",
                :link_name => "http://google.com",
                :link_caption => "Google",
                :link_description => "Google homepage",                
                :picture_link => "http://google.com/favicon.ico", 
                :start_date => campaign.start_date + 1.days,
                :end_date => campaign.end_date + 3.days,                
                :campaign => campaign,
                :categories => [Factory(:category)])
    ad.valid?.should be_false
  end

	it "should not allow too long urls" do
  	campaign = Factory(:active_campaign)
    too_long_url = "http://g#{"o" * 1024}gle.com"
    ad = Ad.new(:message => "message",
                :link => too_long_url,
                :link_name => "http://google.com",
                :link_caption => "Google",
                :link_description => "Google homepage",                
                :picture_link => "http://google.com/favicon.ico", 
                :start_date => Time.now + 1.day + 1.hours,
                :end_date => Time.now + 1.day + 10.hours,                
                :campaign => campaign,
                :categories => [Factory(:category)])
    ad.valid?.should be_false
	end
	
  it "should return active ad" do
    ad = active_ad
    ad.active?.should be_true
  end

#   it "should return the total for all tracking codes" do
#     tracking_code1 = Factory(:tracking_code)
#     ad = tracking_code1.post.ad
#     ad.clicks_count.should == tracking_code1.count
#     Factory :tracking_request, :tracking_code => tracking_code1
#     tracking_code2 = Factory(:tracking_code, :post => tracking_code1.post)
#     Factory :tracking_request, :tracking_code => tracking_code2
#     ad.reload
#     ad.clicks_count.should == tracking_code1.count + tracking_code2.count
#   end

# TODO: (Giacomo -> Jonas) check this test, it is the above refactored
  it "should return the total click counts for valid requests" do
  	post = Factory(:post)
  	ad = post.ad
    Factory :tracking_request, :post => post
    Factory :tracking_request, :post => post
    ad.clicks_count.should == 2
  end

  describe "tracking_requests" do
    it "should return all tracking_requests" do
      advertiser = Factory(:advertiser)
      # Campaign 1
      campaign1 = Factory(:active_campaign, :advertiser => advertiser)
      ad1 = Factory(:ad, :campaign => campaign1)
      post1 = Factory :post, :ad => ad1
      # Campaign 2
      campaign2 = Factory(:active_campaign, :advertiser => advertiser)
      ad2 = Factory(:ad, :campaign => campaign2)
      post2 = Factory :post, :ad => ad2
      # Tracking Request 1
      tracking_request1 = Factory(:tracking_request, :post => post1)
      # Tracking Request 2
      tracking_request2 = Factory(:tracking_request, :post => post2)
      # Publishers per campaign
      ad1.tracking_requests.where(:status => 'PAYABLE')[0].post.should eq(post1)
      ad2.tracking_requests.where(:status => 'PAYABLE')[0].post.should eq(post2)
    end
  end

  describe "clean ad result list" do
    it "should remove ads with 'Not Everyone' visibility" do
      good_ad = Factory :ad
      evil_ad = Factory :ad_adult
      ads_list = Array[good_ad, evil_ad]
      ads_list.count.should eq 2
      clean_ad_list = Ad.clean_ads ads_list
      clean_ad_list.count.should eq 1
    end
  end

  describe "search and filter" do
	  describe "by category" do

			it "should return all ads" do
			    Ad.delete_all
			    market = Factory :market
			    publisher = Factory :publisher
			   	publisher.market = market
					publisher.save!
			    campaign = Factory(:active_campaign)			    
			    campaign.active?.should be_true
			    campaign.save!.should be_true
			    ad = active_ad
			    ad.campaign.market = market
			    ad.campaign.save!			 
			    ad.save!			       
			    Ad.count.should eq 1
			   	ad.campaign.market.should eq publisher.market
			    filtered_ads_list = Ad.filter_ads(publisher, :all)
			    filtered_ads_list.count.should == 1
			  end
      
      it "should return a single ad" do
		    Ad.delete_all
		    market = Factory :market
		    publisher = Factory :publisher
		   	publisher.market = market
				publisher.save!
			  campaign = Factory(:active_campaign)			    
		    campaign.active?.should be_true
		    campaign.save!.should be_true
		    ad = active_ad
		    ad.campaign.market = market
		    ad.campaign.save!			 
		    ad.save!			       
		    Ad.count.should eq 1
		   	ad.campaign.market.should eq publisher.market
        filtered_ads_list = Ad.filter_ads(publisher, ad.categories.first.id)
        filtered_ads_list.count.should eq 1
      end

      it "should return no ads" do
		    Ad.delete_all
		    market = Factory :market
		    publisher = Factory(:publisher, :market => market)
				publisher.save!
			  campaign = Factory(:active_campaign)			    
		    campaign.active?.should be_true
		    campaign.save!.should be_true
		    ad = active_ad
		    ad.save!       
		    Ad.count.should eq 1
        filtered_ads_list = Ad.filter_ads(publisher, :all)
        filtered_ads_list.count.should eq 0
      end
  end

    describe "by keywords" do
      it "should return an ad" do
		    Ad.delete_all
		    market = Factory :market
		    publisher = Factory :publisher
		   	publisher.market = market
				publisher.save!
			  campaign = Factory(:active_campaign)			    
		    campaign.active?.should be_true
		    campaign.save!.should be_true
		    ad = active_ad
		    ad.campaign.market = market
		    ad.campaign.save!			 
		    ad.save!			       
		    Ad.count.should eq 1
		   	ad.campaign.market.should eq publisher.market
        filtered_ads_list = Ad.filter_ads(publisher, :all, "google")
        filtered_ads_list.count.should eq 1
      end

      it "should return no ads" do
        Ad.delete_all

        publisher = Factory :publisher
			  campaign = Factory(:active_campaign)			    
        campaign.active?.should be_true

        ad = Factory :ad, :campaign => campaign
        Ad.count.should eq 1

        filtered_ads_list = Ad.filter_ads(publisher, :all, "notavalidword")
        filtered_ads_list.count.should eq 0
      end
    end
  end

  def generate_1022_chars
    chars = 'http://google.com/id='
    (1..143).each {chars << 'abcdefg'}
    chars
  end
  
  def generate_1029_chars
    chars = 'http://google.com/id='
    (1..144).each {chars << 'abcdefg'}
    chars
  end

  describe "links" do
    it "should save up to 1024 characters" do
      ad = Factory.build(:ad, :link => generate_1022_chars, :picture_link => generate_1022_chars)
      expect {ad.save!}.to change(Ad, :count).by(1)
      Ad.find(ad.id).link.length.should eq 1022
    end
    
    it "should not validate link with size bigger that 1024 characters" do
      ad = Factory.build(:ad, :link => generate_1029_chars, :picture_link => generate_1029_chars)
      ad.valid?.should be_false
    end
  end

end
