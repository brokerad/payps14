class ImpressionController < ApplicationController
	def track_impression
		post = Post.find_by_tracking_code(params[:tracking_code])  	
		if post
  		post.impressions.create
  		redirect_to post.ad.picture_link
    else
      redirect_to "http://www.payps.co/index.php/it/?option=com_content&view=article&id=25"
    end
	end
end
