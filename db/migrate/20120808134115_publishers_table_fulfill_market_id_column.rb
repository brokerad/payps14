class PublishersTableFulfillMarketIdColumn < ActiveRecord::Migration
  def self.up
    # update publishers that have selected just one market
    Market.all.each do |market|
      ActiveRecord::Base.connection.execute "
      update publishers
      set market_id = #{market.id}
      where publishers.id in (
        select pm.publisher_id
        from publisher_markets pm
        where pm.market_id = #{market.id}
        group by pm.publisher_id
        having count(*) < 2
      );"
    end
    
    # update publishers with more that one selected market;
    # update market according to they selected language.
    lang_market=Hash["en" => "USA","it" => "Italy", "pt-BR" => "Brasil"]
    lang_market.each do |k, v| 
    ActiveRecord::Base.connection.execute "
      update publishers
      set market_id = (select id from markets where name = '#{v}')
      where market_id is null
      and language_id = (select id from languages where code = '#{k}')"
    end
  end

  def self.down
    #noop
  end
end
