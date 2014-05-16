class UserRecoveriesController < ApplicationController
  
  helper_method :get_login_path
  
  def email_confirmation
    if user = User.is_email_token_valid?(params[:id])
      user.mark_account_as_verified
      flash[:success] = t("publisher.email.valid_token")
    else
      flash[:error] = t("publisher.email.invalid_token", :url => get_resend_confirmation_email_path)
    end
    redirect_to get_login_path
  end

  def resend_confirmation_email; end

  def resend_confirmation_email_send
    if user = User.get_user_by_email(params[:email])
      user.reset_email_token
      EmailConfirmation.email_confirmation(user).deliver
      flash[:success] = t("publisher.email.token_sent")
      redirect_to get_login_path
    else
      flash.now[:error] = t("publisher.email.email_not_found")
      render 'resend_confirmation_email'
    end
  end

  def password_reset; end

  def password_reset_send
    if user = User.get_user_by_email(params[:email])
      user.reset_password_token
      EmailConfirmation.email_password_recovery(user).deliver
      flash[:success] = t("publisher.email.password_token_sent")
      redirect_to get_login_path
    else
      flash.now[:error] = t("publisher.email.email_not_found")
      render 'password_reset'
    end
  end

  def password_reset_handler
    if @user = User.is_password_token_valid?(params[:id])
      flash.now[:success] = t("publisher.email.valid_password_token")
    else
      flash.now[:error] = t("publisher.email.invalid_password_token", :url => get_reset_password_path)
    end
  end

  def password_reset_submit
    if @user = User.is_password_token_valid?(params[:id])
      if params[:password].size < 4 || params[:password] != params[:password_confirmation]
        flash.now[:error] = t("publisher.email.invalid_password_size_or_confirmation")
        render 'password_reset_handler'
      else
        @user.invalidate_password_token!
        @user.change_password!(params[:password])
        flash[:notice] = t("publisher.email.password_changes")
        current_user_session.destroy if current_user_session
        redirect_to get_login_path
      end
    else
      flash.now[:error] = t("publisher.email.invalid_password_token", :url => get_reset_password_path)
      render 'password_reset_handler'
    end
  end
  
  protected
  
  def get_login_path; root_path; end
  
  def get_reset_password_path; password_reset_path; end
  
  def get_resend_confirmation_email_path; resend_confirmation_email_path; end
end