class Publisher::RegisterFacebookController < ApplicationController
  include FbRedirects

  def new
    cookies[:ptc] = params[:ptc].to_s
    redirect_to "/auth/facebook"
  end

  def fail
    flash[:error] = t("publisher.facebook.fail", :fb_msg => params[:message])
    redirect_to publisher_publisher_login_path
  end

  def create
    fb_user = PublisherFacebook.find_by_uid(request.env["omniauth.auth"]["uid"])
    if fb_user && fb_user.providers && fb_user.providers.split(';').include?('facebook_post') && !fb_user.providers.split(';').include?('facebook')
      flash[:notice] = "You are trying to login/singup with a Facebook account that is already associated to an paypersocial account. Please login with your paypersocial account to continue."
      redirect_to publisher_publisher_login_path
      return
    end
    publisher_facebook = PublisherFacebook.create_from_facebook_data(request.env["omniauth.auth"])
    session[:publisher_facebook_id] = publisher_facebook.id
    user = User.create_from_facebook(publisher_facebook)


    publisher_facebook.create_or_update_account_pages(publisher_facebook.places.find_by_place_type("Account").access_token, true) if publisher_facebook.engaged?

    unless publisher_facebook.publisher
      publisher = Publisher.new(:user => user)
      unless publisher.set_facebook_attributes!(publisher_facebook)
        raise publisher.errors.inspect
      end
    end

    cookies[:ptc] = nil if fb_user # partner can be assigned just to new publishers
    publisher_facebook.publisher.add_tracking_url_by_tracking_code(cookies[:ptc])
    cookies[:ptc] = nil # we do not need this value anymore

    # TODO Extract method
    @user_session = UserSession.new(user)
    if @user_session.save
      flash[:notice] = I18n.t("login.successful")
      redirect_to publisher_facebook_dashboard_path
    else
      # If the user have a forbidden account I redirect him to a forbidden message
       if @user_session.errors[:base].to_s.eql? 'Your account is not active'
        flash[:warning] = t('publisher.disabled')
        redirect_to publisher_info_page_path
       else
        flash[:notice] = I18n.t("login.failed")
        raise @user_session.errors.inspect
        #redirect_to root_path
      end
    end
  end

end
