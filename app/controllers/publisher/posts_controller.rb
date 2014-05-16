class Publisher::PostsController < Publisher::ApplicationController
  include FbRedirects

  def create
    ad = Ad.find(params[:ad_id])
    is_from_fb = params['app_data'] && params['app_data'] == 'facebook_dashboard'
    if ad.campaign.status != Campaign::ACTIVE
      flash[:error] = t("post.created.expired")
      redirect_after_executation(is_from_fb, publisher_publisher_dashboard_path)
    else
      begin
        if current_publisher.engaged?
          current_publisher.publish(ad, params[:message])

          publisher_facebook = current_publisher.publisher_facebooks.first
          publisher_facebook.create_or_update_account_pages(publisher_facebook.places.find_by_place_type("Account").access_token, false)

          flash[:success] = t("post.published")
          redirect_after_executation(is_from_fb, publisher_campaign_reports_path(ad.campaign))
        else
          redirect_to_post_authentication(is_from_fb)
        end
      rescue Exception => e
        handle_post_exception(e, current_publisher, ad, is_from_fb)
      end
    end
  end

end
