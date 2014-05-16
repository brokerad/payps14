class Entry < ActiveRecord::Base
  belongs_to :account
  belongs_to :transaction
  
  scope :not_reconciled_entries, where(:reconciled => false)
  scope :reconciled_entries, where(:reconciled => true)
  scope :credited, where('entries.amount > 0')
  scope :debited, where('entries.amount < 0')
  
  def inverse
    Entry.new(:amount => self.amount * -1,
              :account => self.account,
              :reconciled => true,
              :description => self.description)
  end

  def debit_amount
    amount.abs if amount < 0
  end

  def credit_amount
    amount.abs if amount > 0
  end

  def debit?
    amount < 0
  end

  def credit?
    amount > 0
  end
  
  def self.new_entry(amount, account, reconciled, descr=nil)
    Entry.new(:amount => amount, :account => account, :reconciled => reconciled, :description => descr)
  end
  
  def self.new_not_reconciled(amount, account, descr=nil)
    Entry.new_entry(amount, account, false, descr)
  end

  def self.new_reconciled(amount, account)
    Entry.new_entry(amount, account, true)
  end
end
