class TrackingRequest < ActiveRecord::Base
  PAYABLE                         = "PAYABLE"
  REJECTED                        = "REJECTED"
  PENDING_APPROVAL                = "PENDING_APPROVAL"
  REPEATED_SESSION                = "REPEATED_SESSION"
  REPEATED_IP                     = "REPEATED_IP"
  SKIPPED_BY_ACTION               = "SKIPPED_BY_ACTION"
  SKIPPED_BY_BUDGET               = "SKIPPED_BY_BUDGET"
  SKIPPED_BY_DATE                 = "SKIPPED_BY_DATE"
  SKIPPED_BY_AD_DATE              = "SKIPPED_BY_AD_DATE"
  SKIPPED_BY_FB_BOT               = "SKIPPED_BY_FB_BOT"
  SKIPPED_BY_EMPTY_USER_AGENT     = "SKIPPED_BY_EMPTY_USER_AGENT" # Deprecated
  SKIPPED_BY_UNKNOWN_SOURCE       = "SKIPPED_BY_UNKNOWN_SOURCE"
  SKIPPED_BY_INVALID_USER_AGENT   = "SKIPPED_BY_INVALID_USER_AGENT"
  SKIPPED_BY_EMPTY_REFERER        = "SKIPPED_BY_EMPTY_REFERER"
  SKIPPED_BY_INVALID_REFERER      = "SKIPPED_BY_INVALID_REFERER"
  SKIPPED_BY_WRONG_MARKET         = "SKIPPED_BY_WRONG_MARKET"
  SKIPPED_BY_MAX_NR_CLICKS        = "SKIPPED_BY_MAX_NR_CLICKS" # To be defined

  AVAILABLE_STATUS = [
    SKIPPED_BY_FB_BOT,
    SKIPPED_BY_INVALID_USER_AGENT,
    SKIPPED_BY_UNKNOWN_SOURCE,
    SKIPPED_BY_EMPTY_REFERER,
    SKIPPED_BY_INVALID_REFERER,
    SKIPPED_BY_WRONG_MARKET,
    SKIPPED_BY_ACTION,
    SKIPPED_BY_BUDGET,
    SKIPPED_BY_DATE,
    SKIPPED_BY_AD_DATE,
    REPEATED_SESSION,
    REPEATED_IP,    
    PENDING_APPROVAL,
    REJECTED,
    PAYABLE]

  validates_inclusion_of :status, :in => AVAILABLE_STATUS

  belongs_to :post

  default_scope :order => "tracking_requests.created_at DESC"

  before_save :check_campaign_clicks_number

  def self.payable_clicks
    unscoped.where(:status => PAYABLE)
  end

  def self.update_status campaign, ids, new_status
    trackings = TrackingRequest.scoped(:conditions => {:id => ids})

    if new_status == PAYABLE    
      budget_after_update = campaign.budget - (trackings.count * campaign.click_value)  
      if budget_after_update < 0
        raise "Campaign exceeded the budget."
        end
    end
    
    trackings.update_all(:status => new_status)

    # trackings.each do | tracking |
    #   if new_status == PAYABLE && !campaign.has_budget?
    #     raise "Campaign exceeded the budget."
    #   end
    #   tracking.status = new_status
    #   tracking.save
    # end
    trackings
  end

  # It converts the http header into a hash
	def headers
	  begin
			@headers ||= ActiveSupport::JSON.decode(self.http_headers)
    rescue Exception => e
      logger.error "Invalid json, using entire string. Value: #{self.http_headers}, class: #{self.http_headers.class}"
      @headers ||= self.http_headers
    end
	end

	# It returns the value of the http header
	def header name
		headers && headers.class == Hash && headers[name] ? headers[name] : "unknown"
	end

	# Returns HTTP_REFERER with a space after each ? and & chars
	def referer
    header("HTTP_REFERER").gsub(/([&\?])/, "\\1 ")
	end

  def check_campaign_clicks_number
    if self.status == PAYABLE || self.status == PENDING_APPROVAL
      campaign = post.ad.campaign
      today_clicks = 0


      campaign.ads.each do |ad|
        ad.posts.each do |post|
          today_clicks += post.tracking_requests.where(:created_at => Date.today, :status => PAYABLE).count if self.status == PAYABLE
          today_clicks += post.tracking_requests.where(:created_at => Date.today, :status => PENDING_APPROVAL).count if self.status == PENDING_APPROVAL
        end
      end

      if today_clicks == campaign.max_clicks_per_day
        self.status == SKIPPED_BY_MAX_NR_CLICKS
      end
    end
  end

end
