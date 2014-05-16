module Admin::PublishersHelper
  # This helper method is used to avoid errorns on empty birthday
  def replace_birthday_if(condition, &block)
    if condition
      content_tag("p", t('.no_birthday_available'))
    else
      content_tag("p", &block)
    end
  end
    
  def enable_publisher_button(publisher_id, publisher_enabled)  
    enabled = false
    enabled = true if publisher_enabled.to_s =~ (/(true|t|yes|y|1)$/i)
    if enabled
      title = I18n.t("commons.disable")
      css_class = ""
    else
      title = I18n.t("commons.enable")
      css_class = "success"
    end
    href = admin_publisher_path(publisher_id, :publisher => {:enabled => "#{!enabled}"})
    link_to title, href, :method => :put, :class => "btn " + css_class
  end
end
