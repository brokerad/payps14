require "net/http"

class UrlExistanceValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:link] << I18n.t("ad.validate.url") unless Paypersocial::UrlValidator.is_valid?(record.link)
    record.errors[:picture_link] << I18n.t("ad.validate.url") unless Paypersocial::UrlValidator.is_valid?(record.picture_link)
  end
end