require 'spec_helper'

describe RevenueShare do
  
  describe 'mandatory fields' do
    
    context 'duration' do
      it 'should be presence' do; check_presence(:revenue_share, :duration); end
      it 'should be number' do; check_to_be_numerical(:revenue_share, :duration); end
      it 'should be integer' do; check_to_be_integer(:revenue_share, :duration); end
      it 'should be positiv' do; check_to_be_positive_number(:revenue_share, :duration); end
      it 'should be less or equal to 99' do; less_that_99(:duration); end
    end
    
    context 'revenue' do
      it 'should be presence' do; check_presence(:revenue_share, :revenue); end
      it 'should be number' do; check_to_be_numerical(:revenue_share, :revenue); end
      it 'should be integer' do; check_to_be_integer(:revenue_share, :revenue); end
      it 'should be positiv' do; check_to_be_positive_number(:revenue_share, :revenue); end
      it 'should be less or equal to 99' do; less_that_99(:duration); end
    end
    
    context 'tracking_url' do
      it 'should be presence' do; check_presence(:revenue_share, :tracking_url); end
    end

    context 'dates validation' do
      #TODO:
    end
    
  end
  
  def less_that_99(field)
    pt = Factory.build(:revenue_share, field => 100)
    pt.valid?.should be_false
    pt.errors[field][0].should eq "must be less than or equal to 99"
  end
end
