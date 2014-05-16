class PrepaidPackage < ActiveRecord::Base

  DISCOUNTS = [0, 1, 3, 5, 8, 10, 15, 20]

  validates_inclusion_of :discount, :in => DISCOUNTS

  validates_numericality_of :price, :greater_than => 0

  validates_presence_of :package_code

  before_save :calculate_discount

  scope :active, lambda { where("start_date <= ? and end_date > ?", Time.now.utc, Time.now.utc) }

  before_validation :validate_dates

  def scheduled?(range=active_range)
    Time.now.utc < range.first
  end

  def active?(range=active_range)
    # range.include?(Time.now.utc)
    # <= obj <= end
    n = Time.now.utc
    range.first <= n and n <= range.last
  end

  def finished?(range=active_range)
    range.last < Time.now.utc
  end

  def nominal_discount
    self.budget - self.price
  end

  def discount?
    nominal_discount > 0
  end

  private

  def calculate_discount
    new_budget = self.price * (self.discount / 100.0)
    new_budget = new_budget + self.price
    self.budget = new_budget
  end

  def active_range
    Range.new(self.start_date, self.end_date, true)
  end

  def active_range_was
    Range.new(self.start_date_was, self.end_date_was, true)
  end

  def validate_dates
    if self.end_date < self.start_date
      errors.add(:end_date, I18n.t("prepaid_package.validate.end_date_before_start_date"))
    end
  end
end
