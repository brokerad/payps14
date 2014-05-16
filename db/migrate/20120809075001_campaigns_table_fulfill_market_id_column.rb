class CampaignsTableFulfillMarketIdColumn < ActiveRecord::Migration
  def self.up
    # update campaigns that have selected just one market
    Market.all.each do |market|
      ActiveRecord::Base.connection.execute "
      update campaigns
      set market_id = #{market.id}
      where campaigns.id in (
        select mc.campaign_id
        from market_campaigns mc
        where mc.market_id = #{market.id}
        group by mc.campaign_id
        having count(*) < 2);"
    end
    
    # update campaigns with more that one selected market with 'USA'
    ActiveRecord::Base.connection.execute "
      update campaigns
      set market_id = (select id from markets where name = 'USA')
      where market_id is null;"
  end

  def self.down
    #noop
  end
end
