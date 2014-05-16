module Admin::CampaignsHelper

  # This helper makes the columns sortable
  def sortable(column, title=nil)
    title ||= column.tileize
    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"
    link_to title, :sort => column, :direction => direction
  end
  
  def sortable_campaigns(column, title=nil, advertiser=nil)
    title ||= column.tileize
    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"
    link_to(title, :sort => column, :direction => direction, :advertiser => advertiser)
  end

  def admin_action_button campaign
    class_button = ""
    if campaign.processable?
      link_to "Process", admin_campaign_process_path(campaign)
    elsif campaign.finishable_by_action?
      link_to "Finish", admin_campaign_finish_path(campaign)
    elsif campaign.processed?
      link_to "Re-Process", admin_campaign_reprocess_path(campaign)
    end
  end

  def campaign_activate_button campaign
    class_button = ""
    unless campaign.active?
      link_to "Activate", admin_campaign_activate_path(campaign)
    end
  end
  
  def enable_campaign(campaign_id, campaign_status)
    if campaign_status == Campaign::ACTIVE or campaign_status == Campaign::PAUSED
      if campaign_status == Campaign::ACTIVE
        href = admin_campaign_path(campaign_id, :campaign => {:status => Campaign::PAUSED})
        title = I18n.t("commons.pause")
        css_class = ""
      elsif campaign_status == Campaign::PAUSED
        href = admin_campaign_path(campaign_id, :campaign => {:status => Campaign::ACTIVE})
        title = I18n.t("commons.unpause")
        css_class = "success"
      end
      link_to title, href, :method => :put, :class => "btn " + css_class
    end
  end
  
  def disabled_checkbox(value)
    checked = "checked='checked'" if value
    raw "<input type='checkbox' #{checked} readonly='true' disabled='true' />"
  end
end
