class Publisher::DashboardsController < Publisher::ApplicationController
  
  layout 'publisher/application'
  
  def index
    @current_category = :all
    session[:filter_category] = @current_category
    @ads_available = Ad.filter_ads(current_publisher, @current_category)
  end
  
  def my_ad
    @ads_available = Ad.filter_my_ads(current_publisher)
  end

  def newest_ad
    @current_category = :all
    session[:filter_category] = @current_category
    @ads_available = Ad.filter_ads(current_publisher, @current_category, "", "ads.created_at DESC")
  end
  
  def categoryfilter
    @current_category = params[:category]

    if @current_category.nil? || @current_category == '0'
      session[:filter_category] = :all
      redirect_to publisher_root_path
    else
      session[:filter_category] = @current_category
  
      @ads_available = Ad.filter_ads(current_publisher, @current_category)
      @campaigns_owned = current_publisher.active_campaigns
  
      category = Category.find(@current_category)
      @category_label = category.get_category_name_for_publisher current_publisher
    end
  end

  def auth_posts
    facebook_data = request.env["omniauth.auth"]
    omniauth_params = request.env["omniauth.params"]
    fb_account = PublisherFacebook.find_by_uid(facebook_data["uid"])
    if fb_account && fb_account.publisher.id != current_publisher.id
      flash[:notice] = "Current facebook account is already associated with another paypersocial/facebook account. Have you signed up with another username?"
    else
      fb_account = PublisherFacebook.create_from_facebook_data(request.env["omniauth.auth"])
      fb_account.publisher = current_publisher
      fb_account.save!
      
      # update first_name and last name, just if they are missed
      current_publisher.set_name_from_fb_account(fb_account) if current_publisher.name == 'new'
      if session[:share_auth_failed].to_s == 'yes'
        flash[:notice] = t("post.failed_auth")
      else
        flash[:success] = t("publisher.support.facebook_engaged")
      end
    end
    session[:share_auth_failed] = nil
    if omniauth_params && omniauth_params['app_data'] == 'facebook_dashboard'
      redirect_to publisher_facebook_dashboard_path
    else
      redirect_to publisher_publisher_dashboard_path
    end
  end
  
end