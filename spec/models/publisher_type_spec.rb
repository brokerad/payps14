require 'spec_helper'

describe PublisherType do
  
  context 'create' do
    it 'with success' do
      expect { Factory(:publisher_type) }.to change(PublisherType, :count).by(1)
    end
    
    context 'name' do
      it 'presence' do
        pt = Factory.build(:publisher_type, :name => nil)
        pt.valid?.should be_false 
        pt.errors[:name][0].should eq "can't be blank"
      end

      it 'failed uniques' do
        Factory(:publisher_type)
        pt = Factory.build(:publisher_type)
        pt.valid?.should be_false
        pt.errors[:name][0].should eq 'has already been taken'
      end
    end

    context 'commission failed' do
      it 'presence' do; check_presence(:publisher_type, :commission); end
      it 'less that 0' do; check_to_be_positive_number(:publisher_type, :commission); end
      it 'float numbers' do; check_to_be_integer(:publisher_type, :commission); end
      it 'to be numerical' do; check_to_be_numerical(:publisher_type, :commission); end

      it 'bigger that 100' do
        pt = Factory.build(:publisher_type, :commission => 101)
        pt.valid?.should be_false
        pt.errors[:commission][0].should eq "must be less than or equal to 100"
      end
    end
    
    context 'payment_delay failed' do
      it 'presence' do; check_presence(:publisher_type, :payment_delay); end
      it 'less that 0' do; check_to_be_positive_number(:publisher_type, :payment_delay); end
      it 'float numbers' do; check_to_be_integer(:publisher_type, :payment_delay); end
      it 'to be numerical' do; check_to_be_numerical(:publisher_type, :payment_delay); end
    end
    
    context 'minimal_payment' do
      it 'presence' do; check_presence(:publisher_type, :minimal_payment); end
      it 'less that 0' do; check_to_be_positive_number(:publisher_type, :minimal_payment); end
      it 'to be numerical' do; check_to_be_numerical(:publisher_type, :minimal_payment); end
      it 'to be float' do; check_to_be_float(:publisher_type, :minimal_payment); end
    end
    
  end
  
  context 'destroy' do
    
    it 'if no publishers attached' do
      pt = Factory(:publisher_type)
      expect { pt.destroy }.to change(PublisherType, :count).by(-1)
    end
    
    it 'failed if publishers attached' do
      publisher = Factory(:publisher)
      expect { publisher.publisher_type.destroy }.to change(PublisherType, :count).by(0)
    end
    
    it 'failed if publishers attached with message' do
      publisher = Factory(:publisher)
      publisher.publisher_type.destroy.should be_false
      publisher.publisher_type.errors[:base][0].should eq 'has attached publishers'
    end
    
  end
  
  #NOTE: please be warn that publisher type 'basic' already exists
  # factories.rb, line: publisher_type_basic = Factory(:publisher_type_basic)
  context 'default' do
    
    it 'new record as default: cleanup existing records and setup default to new one' do
      basic = get_basic_publisher;
      basic.is_default.should be_true
      
      gold = Factory(:publisher_type, :name => 'gold')
      silver = Factory(:publisher_type, :name => 'silver')
      
      basic = PublisherType.where(:name => 'basic').first
      gold = PublisherType.find(gold)
      silver = PublisherType.find(silver)
      
      basic.is_default.should be_false
      gold.is_default.should be_false
      silver.is_default.should be_true
    end
    
    it 'setup, then return it' do
      Factory(:publisher_type, :name => 'gold', :is_default => false)
      pt = Factory(:publisher_type, :name => 'silver', :is_default => true)
      Factory(:publisher_type, :name => 'platinum', :is_default => false)
      PublisherType.get_default.should eq PublisherType.find(pt)
    end
    
    it 'not setup and basic do not exists, then return first from list' do
      get_basic_publisher.destroy
      
      Factory(:publisher_type, :name => 'gold', :is_default => false)
      Factory(:publisher_type, :name => 'silver', :is_default => false)
      
      PublisherType.count.should eq 2
      PublisherType.get_default.should be_a PublisherType
    end
    
    it 'not setup, then return: basic' do
      basic = get_basic_publisher; basic.is_default = false; basic.save!
      
      Factory(:publisher_type, :name => 'gold', :is_default => false)
      Factory(:publisher_type, :name => 'silver', :is_default => false)
      
      PublisherType.get_default.name.should eq PublisherType::BASIC      
    end
    
    it 'update record as default: cleanup existing records and setup default to updated one' do
      basic = get_basic_publisher
      gold = Factory(:publisher_type, :name => 'gold')
      silver = Factory(:publisher_type, :name => 'silver')
      silver = PublisherType.find(silver)
      silver.is_default.should be_true
      
      basic = PublisherType.find(basic)
      basic.is_default = true; basic.save!
      
      basic = PublisherType.find(basic)
      silver = PublisherType.find(silver)

      basic.is_default.should be_true
      silver.is_default.should be_false
    end
    
  end
  
  def get_basic_publisher
    PublisherType.where(:name => 'basic').first
  end
end
