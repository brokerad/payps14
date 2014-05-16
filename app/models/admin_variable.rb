class AdminVariable < ActiveRecord::Base
  
  PARTNER_MINUMUM_AMOUNT_FOR_PAY = 'partner_minumum_amount_for_pay'
  
  validates :key, :value, :presence => true 
  
  def self.partner_minumum_amount_for_pay
    AdminVariable.where(:key => PARTNER_MINUMUM_AMOUNT_FOR_PAY).first.value.to_f
  end

end
