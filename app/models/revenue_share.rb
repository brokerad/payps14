# => eligible period of time for RS is count from engage date till engage date + 'duration';

class RevenueShare < ActiveRecord::Base

  default_scope :order => 'start_date ASC'
  belongs_to :tracking_url

  has_many :publishers, :through => :tracking_url

  validates :tracking_url, :duration, :revenue, :presence => true
  validates :duration, :revenue, :numericality =>
    { :only_integer => true, :greater_than_or_equal_to => 0 }
  validate :validate_tracking_url_availability
  validates_with StartAndEndDateValidator

  delegate :partner, :to => :tracking_url

  # revenue_shares > tracking_urls > publishers > places > posts > ads > campaigns
  # This should extract ALL campaigns related to RS
  def campaigns
    ActiveRecord::Base.connection.execute "
      SELECT campaigns.*
      FROM revenue_shares
       JOIN tracking_urls ON revenue_shares.tracking_url_id = tracking_urls.id
       JOIN publishers ON publishers.tracking_url_id = tracking_urls.id
       JOIN places ON places.publisher_id = publishers.id
       JOIN posts ON posts.place_id = places.id
       JOIN ads ON posts.ad_id = ads.id
       JOIN campaigns ON ads.campaign_id = campaigns.id
      WHERE revenue_shares.id = #{self.id}"
  end

  def closed_campaigns
    Campaign.unscoped.select('distinct(campaigns.id)').
      joins(:ads => [:posts => [:place => [:publisher_facebook => [:publisher => [ :tracking_url => :revenue_share]]]]]).
      where('campaigns.status' => Campaign::PROCESSED, 'revenue_shares.id' => id).count
  end

  def matured
    Entry.select('sum(amount) as summ').
      where(:account_id => BillingService.new.revenue_shares_checking_account(self)).not_reconciled_entries.credited.
      first['summ'].to_f.abs
  end

  def requested
    Entry.select('sum(amount) as summ').
      where(:account_id => BillingService.new.revenue_shares_withdrawal_account(self)).not_reconciled_entries.credited.
      first['summ'].to_f.abs
  end

  def payed
    Entry.select('sum(amount) as summ').
      where(:account_id => BillingService.new.revenue_shares_withdrawal_account(self)).reconciled_entries.debited.
      first['summ'].to_f.abs
  end

  def checking_account_entries
    Entry.where(:account_id => BillingService.new.revenue_shares_checking_account(self))
  end

  def withdrawal_account_entries
    Entry.where(:account_id => BillingService.new.revenue_shares_withdrawal_account(self))
  end

  def publisher_entry(entry)
    return if entry.description.blank? || !entry.description.start_with?('Publisher ')
    return if (publisher_id = entry.description.split(' ')[1].to_i) == 0
    return unless publisher = Publisher.find(publisher_id)
    
    publisher_account = BillingService.new.publisher_checking_account(publisher)

    entry.transaction.entries.each do |e|
      if e.account_id == publisher_account.id
        return e
      end
    end
  end

  def commission_earned(publisher)
    commission = 0
    checking_account_entries.credited.each do |entry|
      commission += entry.amount
    end
    commission
  end

  # TODO: remove/refactor next lines. in revenueshare branch line were removed
  # I kept them, because exist references in revenue_shares/show.html.erb view

  ###########
  # STARTS HERE
  def publisher_engadged_until(date)
    self.partner.publishers.where('created_at <= ?', date).count
  end

  def clicks
    # TODO: 2012.05.16 (Giacomo > Jonas): code for clicks count or instruction
    0
  end

  def amount
    # TODO: 2012.05.16 (Giacomo > Jonas): code for amount or instruction
    0
  end
  # ENDS HERE
  ###########

  private

  def validate_tracking_url_availability
    errors.add(:tracking_url_id, I18n.t("revenue_share.validate.tracking_url_invalid")) if is_tracking_url_taken?
  end

  def is_tracking_url_taken?
    rs = RevenueShare.where(:tracking_url_id => tracking_url)
    tracking_url && rs.count > 0 && !rs.include?(self)
  end

end
