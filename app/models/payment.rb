class Payment < ActiveRecord::Base
  BANK_ACCOUNT = "bank_account"
  validates_presence_of :description
  validates_inclusion_of :payment_type, :in => [BANK_ACCOUNT]
end
