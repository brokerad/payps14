require 'spec_helper'

describe Coupon do

  it "should be active with discount" do
    coupon = Factory.create(:coupon)
    coupon.update_attribute(:start_date, Time.now.utc - 1.minutes)
    coupon.active_coupon?.should be_true
    coupon.has_discount?.should be_true
  end
  
  it "should be active without discount" do
    coupon = Factory.create(:coupon, :amount => 0)
    coupon.update_attribute(:start_date, Time.now.utc - 1.minutes)
    coupon.active_coupon?.should be_true
    coupon.has_discount?.should be_false
  end

  it "should be non active if start_date is in future" do
    coupon = Factory.create(:coupon, :start_date => Time.now.utc + 2.days)
    coupon.active_coupon?.should be_false
    Coupon.status(coupon).should eq Coupon::NONACTIVE
  end

  describe 'mandatory field' do
    it 'name should be present' do; check_presence(:coupon, :name); end
    it 'code should be present' do; check_presence(:coupon, :code); end
    it 'total should be present' do; check_presence(:coupon, :total); end
    it 'amount should be present' do; check_presence(:coupon, :amount); end
    it 'partner should be present' do; check_presence(:coupon, :partner_id); end
  end

  describe 'unique field' do
    it 'code should be unique' do ; check_uniqueness(:coupon, :code); end
  end
  
  context 'amount' do
    it 'should be positive' do; check_to_be_positive_number(:coupon, :amount); end
    it 'shuold be decimal' do; check_to_be_float(:coupon, :amount) end
    it 'shuold be numerical' do; check_to_be_numerical(:coupon, :amount) end
  end
  
  context 'total' do
    it 'should be positive' do; check_to_be_positive_number(:coupon, :total); end
    it 'shuold be numerical' do; check_to_be_numerical(:coupon, :total) end
    it 'should be integer' do; check_to_be_integer(:coupon, :total); end
  end
  
  describe 'relationships' do
    context 'tracking url' do
      it 'and coupon should be the same' do
        tu = Factory(:tracking_url)
        expect { Factory(:coupon, :tracking_urls => [tu], :partner => tu.partner) }.to change(Coupon, :count).by(1)
      end
      
      it 'and coupon cannot be different' do
        tu = Factory(:tracking_url)
        expect { Factory(:coupon, :tracking_urls => [tu], :partner => Factory(:partner)) }.to raise_error
      end
    end
  end
  
  context 'update' do
    it 'with success if no publisher used it' do
      coupon = Factory(:coupon, :total => 10, :amount => 10)
      coupon.total = 100
      coupon.amount = 150
      coupon.save.should be_true
      coupon = Coupon.find(coupon.id)
      coupon.total.should eq 100
      coupon.amount.should eq 150
    end
    
    it 'update just active field if any publisher used it' do
      tu = Factory(:tracking_url)
      coupon = Factory(:coupon, :total => 10, :amount => 10, :active => true, :tracking_urls => [tu], :partner => tu.partner)
      publisher = Factory(:publisher, :coupon => coupon, :tracking_url => tu)
      coupon.active = false
      coupon.total = 100
      coupon.amount = 150
      
      coupon.save.should be_false
      
      coupon.errors[:base][0].should eq 'Coupon cannot be update (except active field) because it is used by publishers'
      coupon_up = Coupon.all(force_reload = false)[0]
      coupon_up.total.should eq 10
      coupon_up.amount.should eq 10
      # because of rspec issue with update_attributes, it does not read object from database, but from its cash
      # coupon_up.active.should be_false
    end
  end
  
  context 'destroy' do
    it 'with success if no publisher used it' do
      coupon = Factory(:coupon, :total => 10, :amount => 10)
      coupon.destroy
      coupon.destroyed?.should be_true
    end
    
    it 'throw exception if any publisher used it' do
      tu = Factory(:tracking_url)
      coupon = Factory(:coupon, :tracking_urls => [tu], :partner => tu.partner)
      publisher = Factory(:publisher, :coupon => coupon, :tracking_url => tu)
      coupon.destroy
      coupon.destroyed?.should be_false
      coupon.errors[:base][0].should eq 'Coupon cannot be deleted because it is used by publishers.'
    end
  end
  
end
