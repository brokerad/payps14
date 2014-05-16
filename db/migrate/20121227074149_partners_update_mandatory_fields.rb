class PartnersUpdateMandatoryFields < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      Partner.all.each do |partner|
        user = partner.user || User.new
        user.email = "pps_#{partner.id}@pps.com"
        user.password = Rails.env.production? ? self.generate_password(partner.id) : 'password'
        user.password_confirmation = user.password
        user.is_email_confirmed = true
        user.enabled = true
        user.role = User::PARTNER
        user.save!
        partner.update_attribute(:user_id, user.id)
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      Partner.all.each do |partner|
        partner.user.destroy if partner.user
      end
    end    
  end
  
  def self.generate_password(key)
    Digest::MD5.hexdigest(Time.now.utc.to_i.to_s + key.to_s)
  end
end
