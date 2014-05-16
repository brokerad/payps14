require 'paypersocial/time_interval/time_interval_holder'
require 'paypersocial/time_interval/time_interval_extractor'

module Paypersocial
  def current_utc_time
    Time.now.utc
  end
end