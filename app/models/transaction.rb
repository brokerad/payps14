class Transaction < ActiveRecord::Base
  has_many :entries

  before_validation :validate_balance

  def rejected?
    debit = entries.map{|p| p.debit_amount}
    credit = entries.map{|p| p.credit_amount}
    debit == credit
  end

  private

  def validate_balance
    
    #@entries.each { |entry| logger.debug "---> #{entry.amount}" }
    
    difference = @entries.inject(0) { |sum, entry| sum + entry.amount }
    if difference != 0
      errors.add(:unbalanced_transaction_error,
                 I18n.t("errors.unbalanced_transaction_error",
                        :difference => difference))
    end
  end
end
