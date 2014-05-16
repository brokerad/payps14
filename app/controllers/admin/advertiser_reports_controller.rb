class Admin::AdvertiserReportsController < Admin::ApplicationController
  before_filter :require_user

  def index
    @advertisers = Advertiser.all
  end
end
