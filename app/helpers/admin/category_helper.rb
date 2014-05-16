module Admin::CategoryHelper

  def category_activate_button(category)
     if category.active?
       title = I18n.t("commons.disable")
       css_class = ""
     else
       title = I18n.t("commons.enable")
       css_class = "success"
     end

     href = admin_category_activate_path(category.id)

     link_to "I want to " + title, href, :class => "btn " + css_class
  end
end
