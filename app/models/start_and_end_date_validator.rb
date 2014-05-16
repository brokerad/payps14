class StartAndEndDateValidator < ActiveModel::Validator
  
  def validate(record)
    record.errors[:start_date] << I18n.t("dates.start_date_invalid") unless is_stat_date_valid?(record)
    record.errors[:end_date] << I18n.t("dates.end_date_invalid") unless is_end_date_valid?(record)
  end
  
  def is_stat_date_valid?(record)
    !record.start_date.nil? && record.start_date.future?
  end
  
  def is_end_date_valid?(record)
    is_stat_date_valid?(record) && !record.end_date.nil? && record.end_date >= record.start_date
  end
  
end
