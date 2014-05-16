require 'spec_helper'

describe TrackingUrl do
  
  describe 'create' do
    it 'with success' do
      expect { Factory(:tracking_url) }.to change(TrackingUrl, :count).by(1)      
    end
    
    context 'name' do
      it 'should be unique' do; check_uniqueness(:tracking_url, :name); end
      it 'should be required' do; check_presence(:tracking_url, :name); end
    end
    
    context 'tracking_code' do
      it 'should be unique' do; check_uniqueness(:tracking_url, :tracking_code); end
      it 'should be required' do; check_presence(:tracking_url, :tracking_code); end
    end
    
    context 'lead_url' do
      it 'should be unique' do ; check_uniqueness(:tracking_url, :lead_url); end
      it 'should be required' do; check_presence(:tracking_url, :lead_url); end
    end
    
    context 'partner_id' do
      it 'should be required' do; check_presence(:tracking_url, :partner_id); end
    end
    
  end
  
  describe 'destroy' do
    it 'with success' do
      tu = Factory(:tracking_url)
      expect { tu.destroy }.to change(TrackingUrl, :count).by(-1)
    end
    
    it 'failed if it is attached to a coupon or partner conditions' do
      tu = Factory(:tracking_url)
      pc = Factory(:revenue_share, :tracking_url => tu)
      expect { pc.tracking_url.destroy }.to change(TrackingUrl, :count).by(0)
    end

    it 'failed with message if it is attached to a coupon or partner conditions' do
      tu = Factory(:tracking_url)
      pc = Factory(:revenue_share, :tracking_url => tu)
      pc.tracking_url.destroy
      pc.tracking_url.destroyed?.should be_false
      pc.tracking_url.errors[:base][0].should eq 'Tracking Url cannot be deleted. It has attached coupons or/and partner condition.'
    end
    
  end
  
  describe 'available tracking requests' do
    it 'return available' do
      Factory(:tracking_url); Factory(:tracking_url)
      TrackingUrl.all.count.should eq 2
      TrackingUrl.get_available.count.should eq 2
    end
    
    it 'if it is associated, it should not be in returned list' do
      Factory(:tracking_url)
      tu = Factory(:tracking_url)
      Factory(:revenue_share, :tracking_url => tu)
      TrackingUrl.all.count.should eq 2
      TrackingUrl.get_available.count.should eq 1
    end
  end
  
  it 'should read all its publishers' do
    tu = Factory(:tracking_url)
    Factory(:publisher_engaged, :tracking_url => tu)
    Factory(:publisher_engaged, :tracking_url => tu)
    Factory(:publisher_engaged)
    tu.publishers.count.should eq 2
    Publisher.count.should eq 3
  end

  context 'tracking url can be attached to' do
    
    before(:each) do
      @tracking_url = Factory(:tracking_url)
    end
    
    it 'many coupons' do
      Factory(:coupon, :tracking_urls => [@tracking_url], :partner => @tracking_url.partner)
      Factory(:coupon, :tracking_urls => [@tracking_url], :partner => @tracking_url.partner)
      Coupon.count.should eq 2
      TrackingUrl.find(@tracking_url).coupons.count.should eq 2
    end

    it 'just to one revenue share' do
      Factory(:revenue_share, :tracking_url => @tracking_url)
      expect { Factory(:revenue_share, :tracking_url => @tracking_url) }.to raise_error
    end

    it 'a COUPON, then it CAN be attached to a PARTNER CONDITION' do
      Factory(:coupon, :tracking_urls => [@tracking_url], :partner => @tracking_url.partner)
      Factory(:revenue_share, :tracking_url => @tracking_url)
      Coupon.count.should eq 1
      validate_tr_url
    end

    it 'a PARTNER CONDITION, then it CAN be attached to a COUPON' do
      Factory(:revenue_share, :tracking_url => @tracking_url)
      Factory(:coupon, :tracking_urls => [@tracking_url], :partner => @tracking_url.partner)
      Coupon.count.should eq 1
      validate_tr_url
    end
    
    it 'a PARTNER CONDITION, then it CAN be attached to MANY COUPON' do
      Factory(:revenue_share, :tracking_url => @tracking_url)
      Factory(:coupon, :tracking_urls => [@tracking_url], :partner => @tracking_url.partner)
      Factory(:coupon, :tracking_urls => [@tracking_url], :partner => @tracking_url.partner)
      Coupon.count.should eq 2
      validate_tr_url
      Coupon.all[1].tracking_urls[0].should eq @tracking_url
    end
    
    def validate_tr_url
      RevenueShare.count.should eq 1
      TrackingUrl.count.should eq 1
      
      Coupon.all[0].tracking_urls[0].should eq @tracking_url
      RevenueShare.all[0].tracking_url.should eq @tracking_url
      TrackingUrl.all[0].should eq @tracking_url
    end
  end
  
end
