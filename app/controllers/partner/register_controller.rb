class Partner::RegisterController < ApplicationController
  
  def new
    @partner = Partner.new
    @partner.user = User.new
  end
  
  def create
    @partner = Partner.new(params[:partner])
    if @partner.register!
      EmailConfirmation.email_confirmation(@partner.user).deliver
      flash[:success] = I18n.t("publisher.created.account")
      current_user_session.destroy if current_user_session
      redirect_to partner_login_path
    else
      render :new
    end
  end
  
end