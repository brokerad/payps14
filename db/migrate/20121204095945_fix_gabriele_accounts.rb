class FixGabrieleAccounts < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      Publisher.where(:email => 'paypersocial.webmaster@gmail.com').update_all(:email => 'paypersocial.webmaster-up@gmail.com')
      User.where(:email => 'paypersocial.webmaster@gmail.com').update_all(:email => 'paypersocial.webmaster-up@gmail.com')
      
      Publisher.where(:email=>'gtaviani@paypersocial.com').update_all(:email => 'paypersocial.webmaster@gmail.com')
      User.where(:email=>'gtaviani@paypersocial.com').update_all(:email => 'paypersocial.webmaster@gmail.com')
      
      User.where(:email => 'paypersocial.webmaster@gmail.com').update_all(:role => User::PUBLISHER)
      User.where(:email => 'paypersocial.webmaster@gmail.com').update_all(:is_email_confirmed => true)
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      Publisher.where(:email=>'paypersocial.webmaster@gmail.com').update_all(:email => 'gtaviani@paypersocial.com')
      User.where(:email=>'paypersocial.webmaster@gmail.com').update_all(:email => 'gtaviani@paypersocial.com')
      User.where(:email => 'gtaviani@paypersocial.com').update_all(:role => User::ADMIN)
      
      Publisher.where(:email => 'paypersocial.webmaster-up@gmail.com').update_all(:email => 'paypersocial.webmaster@gmail.com')
      User.where(:email => 'paypersocial.webmaster-up@gmail.com').update_all(:email => 'paypersocial.webmaster@gmail.com')
    end
  end
end
