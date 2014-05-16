class RevenueShareMigrateData < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      Partner.all.each do |partner|
        TrackingUrl.create!(
          :lead_url => partner.lead_url,
          :name => partner.name, 
          :tracking_code => partner.partner_tracking_code,
          :partner_id => partner.id,
          :active => false) if TrackingUrl.find_by_partner_id(partner.id) == nil
      end
      
      Coupon.all.each do |coupon|
        tu = TrackingUrl.find_by_partner_id(coupon.partner_id)
        unless coupon.tracking_urls.include?(tu)
          coupon.tracking_urls << tu
          coupon.save!(:validate => false)
        end
      end
      
      Publisher.where('partner_id is not null').each do |publisher|
        unless publisher.partner_id.blank?
          publisher.tracking_url = TrackingUrl.find_by_partner_id(publisher.partner_id)
          publisher.save!(:validate => false)
        end
      end
      
    end
  end

  def self.down
    #noop
  end
end
