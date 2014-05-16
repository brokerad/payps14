class Admin::ApAdsController < Admin::ApplicationController
  def index
    @ads = Ad.all
  end

end
