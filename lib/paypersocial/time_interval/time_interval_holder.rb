module Paypersocial
  module TimeInterval
    class TimeIntervalHolder
      
      attr_accessor :start_time, :end_time
      def initialize(start_time, end_time)
        raise ArgumentError.new('start_time is not provided') if start_time.nil?
        raise ArgumentError.new('end_time is not provided') if end_time.nil?
        raise ArgumentError.new('end_time cannot be bigger that start_date') if start_time >= end_time
        @start_time, @end_time = start_time, end_time
      end

    end
  end
end