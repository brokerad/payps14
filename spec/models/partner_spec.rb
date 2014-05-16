require 'spec_helper'

describe Partner do

  describe 'create' do
    it 'with success' do
      expect { Factory(:partner) }.to change(Partner, :count).by(1)
    end
  end

  describe 'mandatory fields' do
    context 'name' do
      it 'should be presence' do; check_presence(:partner, :name); end
      it 'should be unique' do; check_uniqueness(:partner, :name); end
    end

    context 'address' do
      it 'should be presence' do; check_presence(:partner, :address); end
    end

    context 'zip' do
      it 'should be presence' do; check_presence(:partner, :zip); end
    end

    context 'city' do
      it 'should be presence' do; check_presence(:partner, :city); end
    end

    context 'country' do
      it 'should be presence' do; check_presence(:partner, :country); end
    end
  end

  describe 'associations' do
    before(:each) do
      @partner = Factory(:partner)
    end

    it 'should read its tracking urls' do
      Factory(:tracking_url)
      Factory(:tracking_url, :partner => @partner)
      Factory(:tracking_url, :partner => @partner)
      @partner.tracking_urls.count.should eq 2
      TrackingUrl.count.should eq 3
    end

    it 'should read its coupons' do
      Factory(:coupon)
      Factory(:coupon, :partner => @partner)
      Factory(:coupon, :partner => @partner)
      @partner.coupons.count.should be 2
      Coupon.count.should eq 3
    end

  end

end
