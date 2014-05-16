module Admin::CampaignDetailedClicksHelper
  def actions(tracking, campaign_processed)
    buttons = ""
    if tracking.status == TrackingRequest::PENDING_APPROVAL
      buttons = self.to_payable(tracking, campaign_processed)
      buttons = buttons + self.to_rejected(tracking, campaign_processed)
    elsif tracking.status == TrackingRequest::PAYABLE
      buttons = self.to_rejected(tracking, campaign_processed)
    elsif tracking.status == TrackingRequest::REJECTED
      buttons = self.to_payable(tracking, campaign_processed)
    else
      buttons = self.to_payable(tracking, campaign_processed)
    end
    raw buttons
  end

  def to_payable(tracking, campaign_processed)
    content_tag :button, "PAY", :name => "PAY", :type => "submit", :class => "btn success mark_as_payable", :disabled => campaign_processed
  end

  def to_rejected(tracking, campaign_processed)
    content_tag :button, "RJC", :name => "RJC", :type => "submit", :class => "btn danger mark_as_rejected", :disabled => campaign_processed
  end
end
