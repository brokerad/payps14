require 'spec_helper'

include Paypersocial::TimeInterval
describe Paypersocial::TimeInterval::TimeIntervalExtractor do
  
  context 'extract method' do
    it 'intervals should not overlap' do
      TimeIntervalExtractor.extract(
        [Time.now.utc + 1.days, Time.now.utc + 5.days], [Time.now.utc - 5.days, Time.now.utc - 1.days]).
        should be_nil
    end

    it 'end_date of first interval should conicide with start_date of second interval' do
      overlap_point = Time.now.utc + 5.days
      TimeIntervalExtractor.extract([Time.now.utc + 1.days, overlap_point], [overlap_point, Time.now.utc + 10.days]).
      should be_nil
    end

    it 'start_date of first interval should conicide with end_date of second interval' do
      overlap_point = Time.now.utc
      TimeIntervalExtractor.extract([overlap_point, Time.now.utc + 5.days], [Time.now.utc - 5.days, overlap_point]).
        should be_nil
    end

    it 'one interval includes another one' do
      start_time, end_time = Time.now.utc - 1.days, Time.now.utc + 1.days
      interval = TimeIntervalExtractor.extract([start_time, end_time], [Time.now.utc - 2.days, Time.now.utc + 2.days])
        
      interval.start_time.should eq start_time
      interval.end_time.should eq end_time
    end

    it 'first interval should include just start_date of second interval' do
      start_time, end_time = Time.now.utc, Time.now.utc + 1.days
      
      interval = TimeIntervalExtractor.extract([Time.now.utc - 1.days, end_time], [start_time, Time.now.utc + 2.days])
        
      interval.start_time.should eq start_time
      interval.end_time.should eq end_time
    end

    it 'first interval should include just end_date of second interval' do
      start_time, end_time = Time.now.utc - 1.days, Time.now.utc
      
      interval = TimeIntervalExtractor.extract([start_time, Time.now.utc + 1.days], [Time.now.utc - 2.days, end_time])

      interval.start_time.should eq start_time
      interval.end_time.should eq end_time
    end

  end
end