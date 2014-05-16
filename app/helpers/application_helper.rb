module ApplicationHelper

  def show_error
    flash[:error] ? show_message(flash[:error], "error") : ''
  end

  def show_warning
    flash[:warning] ? show_message(flash[:warning], "warning") : ''
  end

  def show_notice
    flash[:notice] ? show_message(flash[:notice], "notice") : ''
  end

  def show_success
    flash[:success] ? show_message(flash[:success], "success") : ''
  end

  def show_message(msg = "", css_class_name = "notice")
    msg ? '<div class="alert-message ' + css_class_name + '"><a class="close" href="#">x</a>' + msg + '</div>' : ''
  end

  def show_messages_flash
    show_success + show_notice + show_warning + show_error
  end

  def currency_format(number)
    number_to_currency number, :locale => "en", :format => "%u %n"
  end
  
  def isPPSuser(publisher)
    in_array = [ 
      'gantonelli@paypersocial.com', 
      'afenati@paypersocial.com', 
      'aborsari@paypersocial.com',
      'fabio@slytrade.com',  
      ].include? publisher.email
    in_array or Rails.env.development?
  end
  
  def value_or_zero hash, key
    hash[key].nil? ? '0' : hash[key]
  end
  
  def default_time_format
    "%d/%m/%Y %H:%M"
  end
  
  def date_only_format
    "%d/%m/%Y"
  end
  
  def extract_facebook_link_if publisher
    if publisher.publisher_facebooks && publisher.publisher_facebooks.size > 0
      get_facebook_link(publisher.publisher_facebooks[0])
    else
      default_no_fb_tag
    end
  end
  
  def get_facebook_link fb_publisher
    user_hash = fb_publisher.account_raw_info if fb_publisher
    if user_hash && user_hash["link"]
      link_to("Open link", user_hash["link"], :target => :blank) 
    else
      default_no_fb_tag
    end
  end

  def banner_for_page page, lang=nil
    lang = (params[:locale] || I18n.default_locale) if lang.nil?
    banner = Banner.get_banner page, lang
    if banner
      if banner.target_url? 
        link_to(image_tag(banner.image_url.to_s), banner.target_url, :target => :blank) 
      else
        image_tag(banner.image_url.to_s) 
      end
    end
  end
  
  private
  
  def default_no_fb_tag
    content_tag :p, "No facebook account available"
  end
  
end
