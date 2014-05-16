require "base62"

class SetNewSeqForPosts < ActiveRecord::Migration
  def self.up
  	tc = Post.last  	
  	ActiveRecord::Base.connection.execute "SELECT setval('posts_id_seq', #{tc.tracking_code.base62_decode})"
  end

  def self.down
  end
end
