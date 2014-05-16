class Account < ActiveRecord::Base
  ROOT_NATURE = 0
  DEBIT_NATURE = 1
  CREDIT_NATURE = 2
  MIXED_NATURE = 3

  def self.valid_natures
    [ROOT_NATURE, DEBIT_NATURE, CREDIT_NATURE, MIXED_NATURE]
  end

  has_many   :children, :class_name => "Account", :foreign_key => "parent_id", :dependent => :restrict
  belongs_to :parent,   :class_name => "Account", :foreign_key => "parent_id"

  has_many   :entries, :dependent => :restrict

  validates :name, :presence => true,
                   :uniqueness => { :scope => :parent_id }

  validates :nature, :presence => true,
                     :inclusion => { :in => Account.valid_natures }

  def balance
    balance_children + balance_entries
  end

  def balance_unreconciled
    balance_unreconciled_children + balance_unreconciled_entries
  end

  def balance_reconciled
    balance_reconciled_children + balance_reconciled_entries
  end

  def child(name)
    children.select { |account| account.name == name.to_s }.first
  end

  def all_entries
    result = []
    result.concat(entries)
    children.each {|child| result.concat(child.all_entries) }
    result
  end

  def children_unreconciled_entries
    Entry.not_reconciled_entries.joins(:account).where("accounts.parent_id" => id).readonly(false)
  end
  
  def unreconciled_entries
    Entry.not_reconciled_entries.joins(:account).where("accounts.id" => id).readonly(false)
  end

  def all_reconciled_entries
    all_entries.select {|e| e.reconciled?}
  end

  def debit_entries
    all_entries.select {|entry| entry.debit?}
  end

  def total_debit
    debit_entries.collect {|entry| entry.amount}.sum.abs
  end

  def all_credit_entries
    all_entries.select {|entry| entry.credit?}
  end
  
  def children_credit_entries
    Entry.credited.joins(:account).where("accounts.parent_id" => id)
  end
  
  def credit_entries
    Entry.credited.joins(:account).where("accounts.id" => id, :reconciled => false)
  end
  
  def cashed_entries
    Entry.credited.joins(:account).where("accounts.id" => id, :reconciled => true)
  end

  def total_credit
    all_credit_entries.collect {|e| e.amount}.sum.abs
  end

  private

  def balance_children
    children.inject(0) { |sum, acc| sum + acc.balance }
  end

  def balance_entries
    entries.inject(0) { |sum, entry| sum + entry.amount }
  end

  def balance_unreconciled_children
    children.inject(0) { |sum, acc| sum + acc.balance_unreconciled }
  end

  def balance_unreconciled_entries
    entries.select {|e| !e.reconciled}.inject(0) { |sum, entry| sum + entry.amount }
  end

  def balance_reconciled_children
    children.inject(0) { |sum, acc| sum + acc.balance_reconciled }
  end

  def balance_reconciled_entries
    entries.select {|e| e.reconciled}.inject(0) { |sum, entry| sum + entry.amount }
  end
end
