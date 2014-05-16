class AddUkMarket < ActiveRecord::Migration
  def self.up
    Market.create :name => "UK"
  end

  def self.down
    @market = Market.findByName("UK")
    @market.destroy
  end
end
