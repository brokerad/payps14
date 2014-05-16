require 'spec_helper'

include Paypersocial::TimeInterval
describe Paypersocial::TimeInterval::TimeIntervalHolder do

  context 'initialize' do
    it 'should raise exception if no start_date is provided' do
      sd = Time.now.utc - 1.days
      ed = Time.now.utc + 1.days
      interval = TimeIntervalHolder.new(sd, ed)
      interval.start_time.should eq sd
      interval.end_time.should eq ed
    end

    it 'should raise exception if no start_date is provided' do
      expect { TimeIntervalHolder.new(nil, Time.now.utc)
      }.to raise_error(ArgumentError, 'start_time is not provided')
    end

    it 'should raise exception if no end_date is provided' do
      expect { TimeIntervalHolder.new(Time.now.utc, nil)
      }.to raise_error(ArgumentError, 'end_time is not provided')
    end

    it 'should raise exception if no start_date is bigger that end_date' do
      expect { TimeIntervalHolder.new(Time.now.utc + 1.days, Time.now.utc)
      }.to raise_error(ArgumentError, 'end_time cannot be bigger that start_date')
    end

    it 'should raise exception if no start_date is equal with end_date' do
      expect { TimeIntervalHolder.new(t = Time.now.utc, t)
      }.to raise_error(ArgumentError, 'end_time cannot be bigger that start_date')
    end
  end
  
end
