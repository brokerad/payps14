class PartnerConditionsDateToDatetime < ActiveRecord::Migration
  def self.up
    change_column(:partner_conditions, :start_date, :datetime)
    change_column(:partner_conditions, :end_date, :datetime)
  end

  def self.down
    change_column(:partner_conditions, :start_date, :date)
    change_column(:partner_conditions, :end_date, :date)
  end
end
