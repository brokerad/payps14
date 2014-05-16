class FixClickStatusName < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute(" UPDATE tracking_requests
                                            SET status = 'SKIPPED_BY_EMPTY_USER_AGENT'
                                            WHERE status = 'SKIPPED_BY_EMPTY_USERAGENT'") 
    ActiveRecord::Base.connection.execute(" UPDATE tracking_requests
                                            SET status = 'SKIPPED_BY_WRONG_MARKET'
                                            WHERE status = 'SKYPPED_BY_WRONG_MARKET'") 
  end

  def self.down
    ActiveRecord::Base.connection.execute(" UPDATE tracking_requests
                                            SET status = 'SKIPPED_BY_EMPTY_USERAGENT'
                                            WHERE status = 'SKIPPED_BY_EMPTY_USER_AGENT'") 
    ActiveRecord::Base.connection.execute(" UPDATE tracking_requests
                                            SET status = 'SKYPPED_BY_WRONG_MARKET'
                                            WHERE status = 'SKIPPED_BY_WRONG_MARKET'") 
  end
end
