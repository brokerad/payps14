require "base62"

class RemoveTrackingCodesTable < ActiveRecord::Migration
  def self.up
  	add_column :posts, :tracking_code, :string
  	add_column :tracking_requests, :post_id, :integer  	
  	add_column :posts, :target_url, :string
  	add_index :posts, :tracking_code, :unique => true
		
  	# Fixing campaign preferred post times
    Campaign.all.select {|c| c.post_times.empty?}.each do |campaign|
      (1..24).each do |pt|
      	post_time = PostTime.find(pt)
        CampaignPreferedPostTime.create! :campaign => campaign, :post_time => post_time
      end
    end
  	
    puts "Moving data from tracking_codes to posts..."
    ActiveRecord::Base.connection.execute "
      UPDATE posts
      SET tracking_code = (SELECT id
                           FROM tracking_codes
                           WHERE post_id = posts.id
                           ORDER BY id
                           LIMIT 1),
          target_url = (SELECT target_url
                        FROM tracking_codes
                        WHERE post_id = posts.id
                        ORDER BY id
                        LIMIT 1)"
    puts "Encoding in base62 posts.tracking_code..."
    Post.find_each do |post|
      post.tracking_code = post.tracking_code.to_i.base62_encode
      post.save! :validate => false
    end
    puts "Moving data from tracking_codes to tracking_requests..."
    ActiveRecord::Base.connection.execute "
      UPDATE tracking_requests
      SET post_id = tracking_codes.post_id
      FROM tracking_codes
      WHERE tracking_requests.tracking_code_id = tracking_codes.id"
    puts "Finished!"
		
  	remove_column :tracking_requests, :tracking_code_id 
		drop_table :tracking_codes  	
  end

  def self.down
  	remove_column :posts, :tracking_code 
  	remove_column :posts, :target_url
  	remove_column :tracking_requests, :post_id   	
  end
end
