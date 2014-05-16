class AdsTableChangeLinkColumnType < ActiveRecord::Migration
  def self.up
    change_column :ads, :link, :text, :limit => nil
  end

  def self.down
    #to not convert back; can loose data
  end
end
