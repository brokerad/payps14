require "open-uri"
require 'paypersocial'
class TrackingCodesController < ActionController::Base
  include Paypersocial
  IP_MAX_OCCUR = 4
  BANNED_IP_EXPIRED = 5.minutes
  TIMESTAMP_IP_LIST_EXPIRED = 3.minutes
  
  def show
    ip = request.ip
    time = Time.now
    timestamp = time.to_f

    filter_click
    
#     if ($redis.sismember "banned:ip" , ip)  	
#       if Time.parse($redis.get "banned:#{ip}:expired") < time 
#         $redis.srem "banned:ip" , ip
#         $redis.del "banned:#{ip}:expired"
#         $redis.zadd "timestamp:#{ip}:list", 1, timestamp
#         filter_click
#       end	       
#     else
#       score = $redis.zcard "timestamp:#{ip}:list"
#       score = score.next
#       $redis.zadd "timestamp:#{ip}:list", score, timestamp
#       if constant_ip? ip
#         $redis.zremrangebyrank "timestamp:#{ip}:list", 0, -1	     		
#       else
#         #it deletes the sorted set with the timestamps.
#         first_timestamp = ($redis.zrevrange("timestamp:#{ip}:list", -1, -1).first).to_f
#         if (first_timestamp + TIMESTAMP_IP_LIST_EXPIRED.to_f)  < timestamp 
#           $redis.zremrangebyrank "timestamp:#{ip}:list", 0, -1  	  	 	 
#         end  
#         filter_click
#       end         	    
#     end 		
  end
  
  def filter_click
    post = Post.find_by_tracking_code(params[:tracking_code])
    # if tracking_code.image?
    #   image = open(tracking_code.target_url)
    #   render :text => image.read, :content_type => image.content_type
    # else
    session[:force_session_creation] = "do_not_delete_it"
		
		# I'm building a new hash from request.env with uppercase keys only because rack env vars are added by default and they can't be converted to JSON 		
		http_header = Hash.new
		request.env.each do |key, value|
			http_header[ "#{key}" ] = value if key.match(/[A-Z](_[A-Z])?$/)
		end
    
    tr = TrackingRequest.create(
      :ip => request.ip,
      :post_id => post.id,
      :session_id => session[:session_id],
      :status => TrackingRequestAnalyser.status(request, current_utc_time, post),
      :http_headers => http_header.to_json)
          
    # ACCEPTED 
    if  tr.status == TrackingRequest::REPEATED_SESSION              || 
        tr.status == TrackingRequest::REPEATED_IP                   || 
        tr.status == TrackingRequest::SKIPPED_BY_ACTION             || 
        tr.status == TrackingRequest::SKIPPED_BY_DATE               || 
        tr.status == TrackingRequest::SKIPPED_BY_AD_DATE            || 
        tr.status == TrackingRequest::SKIPPED_BY_BUDGET             || 
        tr.status == TrackingRequest::SKIPPED_BY_WRONG_MARKET       || 
        tr.status == TrackingRequest::PAYABLE                      
        redirect_to post.target_url, :status => 302
    else
      # NOT ACCEPTED 
      #tr.status == TrackingRequest::PENDING_APPROVAL               || 
      #tr.status ==TrackingRequest::SKIPPED_BY_FB_BOT               || 
      #tr.status == TrackingRequest::SKIPPED_BY_EMPTY_REFERER       || 
      #tr.status == TrackingRequest::SKIPPED_BY_INVALID_REFERER     || 
      #tr.status == TrackingRequest::SKIPPED_BY_INVALID_USER_AGENT  || 
      #tr.status == TrackingRequest::SKIPPED_BY_UNKNOWN_SOURCE      || 
      redirect_to "http://www.slytrade.com/index.php/it/?option=com_content&view=article&id=25"
    end
  end
  
  def constant_ip?(ip) 
    score = $redis.zcard "timestamp:#{ip}:list"
    time_list = $redis.zrange "timestamp:#{ip}:list", 0, -1
    limit_comp = 3
    limit_comp = 2 if score >=6
    constant_ip_result = false
    if score > IP_MAX_OCCUR      
      last_time = time_list[score - 1]
      second_last_time = time_list[score - 2]
      diff = last_time.to_f - second_last_time.to_f
      constant_ip_result = true
      i = score - 2 
      count_comp = 1 
      while i >= 1
      	time1 = time_list[i]
      	time2 = time_list[i - 1]
        timeDiff = time1.to_f - time2.to_f
         if (timeDiff >= (diff - 1)) && (timeDiff <= (diff + 1)) 
          count_comp = count_comp.next
          if count_comp == limit_comp
            break   
          end         
        else
          constant_ip_result = false
          break
        end
       	 i = i - 1   
       end
     end
    if constant_ip_result == true           
      $redis.sadd "banned:ip" , ip
      $redis.set "banned:#{ip}:expired" , Time.now.utc + BANNED_IP_EXPIRED
      return true       
    end
    return constant_ip_result
  end

  def delTimestampIpListExpired ip, timenow
	  first_timestamp = getParseTimestampTo_f($redis.zrevrange("timestamp:#{ip}:list", -1, -1).first)
	  if (first_timestamp + TIMESTAMP_IP_LIST_EXPIRED.to_f)  < timenow.to_f 
	  	 $redis.zremrangebyrank "timestamp:#{ip}:list", 0, -1  	  	 	 
	  end 
  end
end
