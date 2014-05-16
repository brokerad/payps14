module Admin::TermsHelper
  def enable_term_button(term)
    if term.enabled?
      title = "I want to " + I18n.t("commons.disable")
      css_class = ""
    else
      title = "I want to " + I18n.t("commons.enable")
      css_class = "success"
    end
    href = admin_term_path(term, :term => {:enabled => "#{!term.enabled}"})
    link_to title, href, :method => :put, :class => "btn " + css_class
  end
end
