class PrepaidPackagesConvertDateToDatetime < ActiveRecord::Migration
  def self.up
    change_column(:prepaid_packages, :start_date, :datetime)
    change_column(:prepaid_packages, :end_date, :datetime)
  end

  def self.down
    change_column(:prepaid_packages, :start_date, :date)
    change_column(:prepaid_packages, :end_date, :date)
  end
end
