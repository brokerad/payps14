module Admin::AdvertisersHelper
  def enable_button(advertiser)
    class_button = ""
    if advertiser.user.enabled?
      title = I18n.t("commons.disable")
    else
      title = I18n.t("commons.enable")
      class_button = " success"
    end
    href = admin_advertiser_path(advertiser, :advertiser => {:user_attributes => {:id => "#{advertiser.user.id}", :enabled => "#{!advertiser.user.enabled}"}})
    link_to title, href, :method => :put, :class => "btn" + class_button
  end
end
