class Advertiser::AdvertisersController < Advertiser::ApplicationController
  layout "application"

  before_filter :require_user, :except => [:new, :create]

  def new
    @advertiser = Advertiser.new
    @advertiser.user = User.new
  end

  def create
    @advertiser = Advertiser.new(params[:advertiser])
    @advertiser.user = User.new(params[:advertiser][:user_attributes])
    if @advertiser.save
      flash[:notice] = I18n.t("advertiser.created.success")
    else
      render :action => "new"
    end
  end
end
