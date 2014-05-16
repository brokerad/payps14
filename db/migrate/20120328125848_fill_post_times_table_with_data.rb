class FillPostTimesTableWithData < ActiveRecord::Migration
  def self.up
		PostTime.create!((0..23).collect {|i| {:post_time => i}})
  end

  def self.down
	  PostTime.destroy_all
  end
end
