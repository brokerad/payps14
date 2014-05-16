class EmailConfirmation < ActionMailer::Base

  def email_confirmation(account)
    subject = "Welcome to %s"
    send_email_to_account(account, subject, email_confirmation_path, account.email_token)
  end

  def email_password_recovery(account)
    subject = "Password recovery for %s site"
    send_email_to_account(account, subject, password_reset_handler_path, account.password_token)
  end
  
  private
  
  def send_email_to_account(account, subject, path, token)
    @site_name = Paypersocial::Constants::SITE_TITLE
    @current_host_with_port = Paypersocial::Constants::DOMAIN_URL
    @url_to_follow = "#{@current_host_with_port}#{path}?id=#{token}"
    from = "#{@site_name} <#{Paypersocial::Constants::EMAIL_FROM}>"
    subject = subject % @site_name
    begin
      mail(:to => account.email, :subject => subject, :from => from)
    rescue => exception
      logger.error "::::::ERROR:: error sending  email with subject: #{subject}, to account: #{account.email}."
      logger.error Time.now.utc
      logger.error exception.to_s
      logger.error exception.backtrace.join("\n")
    end
  end
  
end
