module FbRedirects

  def redirect_to_post_authentication(is_from_fb)
    session[:share_auth_failed] = 'yes'
    redirect_to is_from_fb ? '/auth/facebook_post?app_data=facebook_dashboard' : '/auth/facebook_post'
  end

  def redirect_after_executation(is_fb_dashboard, web_redirect)
    redirect_to is_fb_dashboard ? publisher_facebook_dashboard_path : web_redirect
  end


  def handle_post_exception(e, current_publisher, ad, is_from_fb)
    logger.error "::::::ERROR:: error message: #{e.message}"
    logger.error "::::::ERROR:: error during sharing process for publisher: #{current_publisher.inspect}, ad: #{ad.inspect}."
    logger.error e.backtrace.join("\n")
    if e.message.include?('OAuthException')
      redirect_to_post_authentication(is_from_fb)
    else
      flash[:notice] = t("post.failed")
      redirect_after_executation(is_from_fb, publisher_publisher_dashboard_path)
    end
  end
end