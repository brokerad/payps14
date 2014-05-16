class Publisher::RegisterPaypersocialController < ApplicationController
  
  layout 'publisher/dashboard'
  
  def new
    cookies[:ptc] = params[:ptc].to_s
    @publisher = Publisher.new
    @publisher.user = User.new
  end

  def create
    @publisher = Publisher.new(params[:publisher])
    @publisher.user.set_new_email_token
    @publisher.user.enabled = true
    @publisher.email = @publisher.user.email
    if @publisher.save
      EmailConfirmation.email_confirmation(@publisher.user).deliver
      @publisher.add_tracking_url_by_tracking_code(cookies[:ptc])
      cookies[:ptc] = nil # we do not need this value anymore
    
      flash[:success] = I18n.t("publisher.created.account")
      current_user_session.destroy if current_user_session
      redirect_to publisher_publisher_login_path
    else
      render :action => "new"
    end
  end

end
