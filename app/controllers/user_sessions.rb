module UserSessions
  def new
    @user_session = UserSession.new
  end

  def create(default_logged_in_path)
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:success] = I18n.t("login.successful")
      redirect_back_or_default default_logged_in_path
    else
      flash[:error] = I18n.t('login.failed')
      if @user_session.errors.size > 0 && @user_session.errors.full_messages
        flash[:error] << ": #{@user_session.errors.full_messages[0]}" 
      end
      render :action => :new
    end
  end

  def destroy(logged_out_path)
    current_user_session.destroy if current_user_session
    flash[:notice] = I18n.t("user_session.logout.successful")
    redirect_to logged_out_path
  end
end
