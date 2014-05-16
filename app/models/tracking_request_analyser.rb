class TrackingRequestAnalyser
  include Geokit::Geocoders

  MAXIMUM_PER_IP = 5
  TIME_DIFF = 1.hour

#   def self.status request, click_time, post
#     ad          = post.ad
#     campaign    = ad.campaign
#     http_header = request.env
#     http_header['HTTP_REFERER'] = '' unless http_header['HTTP_REFERER']
#     
#     if http_header['HTTP_USER_AGENT'].nil? && http_header['HTTP_REFERER'].empty?
#       return status = TrackingRequest::SKIPPED_BY_EMPTY_USER_AGENT
#     end
# 
#     if is_facebook_bot?(http_header, post, click_time)
#       status = TrackingRequest::SKIPPED_BY_FB_BOT
#     else
#       if http_header['HTTP_REFERER'].empty?
#         if black_list_include?(http_header) || ! is_valid_user_agent?(http_header)
#           status = TrackingRequest::SKIPPED_BY_INVALID_USER_AGENT
#         else
#           status = main_chain(ad, campaign, http_header, post, request, click_time)
#           status = TrackingRequest::PENDING_APPROVAL if status == TrackingRequest::PAYABLE
#         end
#       else
#         if white_list_include?(http_header)
#           if black_list_include?(http_header) || ! is_valid_user_agent?(http_header)
#             status = TrackingRequest::SKIPPED_BY_INVALID_USER_AGENT
#           else
#             status = main_chain(ad, campaign, http_header, post, request, click_time)
#           end
#         else
#           if black_list_include?(http_header) || ! is_valid_user_agent?(http_header)
#             status = TrackingRequest::SKIPPED_BY_INVALID_REFERER
#           else
#             status = main_chain(ad, campaign, http_header, post, request, click_time)
#             status = TrackingRequest::PENDING_APPROVAL if status == TrackingRequest::PAYABLE
#           end
#         end
#       end
#     end
#     status
#   end
  def self.status request, click_time, post
    ad          = post.ad
    campaign    = ad.campaign
    http_header = request.env
    http_header['HTTP_REFERER']     = '' unless http_header['HTTP_REFERER']
    http_header['HTTP_USER_AGENT']  = '' unless http_header['HTTP_USER_AGENT']
    
    return TrackingRequest::SKIPPED_BY_UNKNOWN_SOURCE if http_header['HTTP_USER_AGENT'].empty? && http_header['HTTP_REFERER'].empty?
    return TrackingRequest::SKIPPED_BY_FB_BOT if is_facebook_bot?(request)   
    
    if http_header['HTTP_REFERER'].empty?
      if black_list_include?(http_header)
        return TrackingRequest::SKIPPED_BY_INVALID_USER_AGENT
      else
        return TrackingRequest::SKIPPED_BY_EMPTY_REFERER
      end
    else
      if white_list_include?(http_header)
        return main_chain(ad, campaign, http_header, post, request, click_time)
      else
        return TrackingRequest::SKIPPED_BY_INVALID_REFERER
      end
    end
      return TrackingRequest::PENDING_APPROVAL # Non dovrebbe mai arrivare qui!
  end
  
  # Valid if not nil AND not empty
  def self.is_valid_user_agent?(header)
    ! header['HTTP_USER_AGENT'].nil? && ! header['HTTP_USER_AGENT'].empty? ? true : false
  end
  
  def self.is_facebook_bot?(request)
    ip_class_list = Paypersocial::Constants::FACEBOOK_BOT_IP.split
    facebook_bot_res = false
    
    ip_class_list.each do |el|
    	el_ip_class = el.split('/')
    	el_ip = el_ip_class[0].split('.')
    	el_ip_request = request.ip.split('.')
    		if el_ip[0] == el_ip_request[0]
    			if el_ip[1] == el_ip_request[1]
    				n_class = el_ip_class[1].to_i
    				n_class = 24 - n_class
    				ip_min = el_ip[2].to_i
    				ip_max = el_ip[2].to_i + (2**n_class - 1)    	
    				if (el_ip_request[2].to_i >= ip_min) && (el_ip_request[2].to_i <= ip_max)
	    				facebook_bot_res = true
	    				break					
	    			else
	    				next
	    			end
	    		else
	    			next
	    		end
	    	else
	    		next
	    	end							
    end
    return facebook_bot_res
  end

  def self.is_facebook_user_agent?(user_agent)
    #(Paypersocial::Constants::FACEBOOK_BOT_USER_AGENT.include?(user_agent.to_s)) ? true : false 
    Paypersocial::Constants::FACEBOOK_BOT_USER_AGENT.any? { |agent| user_agent.to_s.include? agent }
  end

  def self.black_list_include?(header)
    #BotUserAgent.active_user_agents.any? { |agent| agent.include? header['HTTP_USER_AGENT'].to_s }
    BotUserAgent.active_user_agents.any? { |agent| header['HTTP_USER_AGENT'].to_s.include? agent }
  end

  def self.white_list_include?(header)
    if (is_facebook_referer?(header['HTTP_REFERER']) ||
        is_twitter_referer?(header['HTTP_REFERER'])  ||
        is_third_party_referer?(header['HTTP_REFERER']))
      return true
    end
    false
  end

  def self.is_facebook_referer?(url)
    url =~ Paypersocial::Constants::FACEBOOK_PATERN
  end

  def self.is_twitter_referer?(url)
    url =~ Paypersocial::Constants::TWITTER_PATERN
  end

  def self.is_third_party_referer?(url)
    url =~ Paypersocial::Constants::THIRD_PARTY_PATERN
  end

  def self.main_chain(ad, campaign, http_header, post, request, time)
    if campaign.finished_by_date?
      TrackingRequest::SKIPPED_BY_DATE

    elsif ad.finished_by_date?
      TrackingRequest::SKIPPED_BY_AD_DATE

    elsif campaign.finished_by_budget?
      TrackingRequest::SKIPPED_BY_BUDGET
      
    elsif ! campaign.finished_by_budget? && ! campaign.has_budget?
      campaign.finish_by_budget
      TrackingRequest::SKIPPED_BY_BUDGET
    
    elsif campaign.finished_by_action?
      TrackingRequest::SKIPPED_BY_ACTION

    elsif known_by_session? post, request.session[:session_id]
      TrackingRequest::REPEATED_SESSION

    elsif known_by_ip? request.ip, time
      TrackingRequest::REPEATED_IP
     
    elsif wrong_market? campaign, request, http_header
      TrackingRequest::SKIPPED_BY_WRONG_MARKET
    
    else
      TrackingRequest::PAYABLE
    end
  end

  def self.known_by_session? post, session_id
    TrackingRequest.where(:post_id => post.id, :session_id => session_id).count > 0
  end

  def self.known_by_ip?(ip, time)
    TrackingRequest.where("ip = ? AND created_at > ?", ip, time - TIME_DIFF).count >= MAXIMUM_PER_IP
  end

  def self.wrong_market? campaign, request, header
    return false if Rails.env.development?
    
    # WRONG_MARKET should be have a valid REFERER 
    if white_list_include?(header)
      res = MultiGeocoder.geocode(request.ip)
      if !res.nil? && (campaign.market.iso_code != res.country_code)
      	return true
      else
      	return false 
      end    
    else
      return false
    end
  end
end
