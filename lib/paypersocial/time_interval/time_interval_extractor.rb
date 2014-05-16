module Paypersocial
  module TimeInterval
    class TimeIntervalExtractor
      
      class << self
        
        def extract(interval1, interval2)
          begin
            ti1 = TimeIntervalHolder.new(interval1[0], interval1[1])
            ti2 = TimeIntervalHolder.new(interval2[0], interval2[1])
            TimeIntervalHolder.new(extract_start_time(ti1, ti2), extract_end_time(ti1, ti2))
          rescue ArgumentError
            nil
          end
        end
        
        private

        def extract_start_time(interval1, interval2)
          if (interval1.start_time.to_i..interval1.end_time.to_i).include?(interval2.start_time.to_i)
            interval2.start_time
          elsif (interval2.start_time.to_i..interval2.end_time.to_i).include?(interval1.start_time.to_i)
            interval1.start_time
          else
            nil
          end
        end

        def extract_end_time(interval1, interval2)
          if (interval1.start_time.to_i..interval1.end_time.to_i).include?(interval2.end_time.to_i)
            interval2.end_time
          elsif (interval2.start_time.to_i..interval2.end_time.to_i).include?(interval1.end_time.to_i)
            interval1.end_time
          else
            nil
          end
        end
      end

    end
  end
end