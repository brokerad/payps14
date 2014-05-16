class Admin::AdvertisersController < Admin::ApplicationController
  skip_before_filter :require_user, :only => [:new, :create]

  def index
    @advertisers = Advertiser.all
  end

  def update
    @advertiser = Advertiser.find(params[:id])

    if params[:advertiser][:new_password]
      @advertiser.user.password = params[:advertiser][:new_password]
      @advertiser.user.password_confirmation = params[:advertiser][:new_password]
      @advertiser.user.save!
    end

    @advertiser.update_attributes!(params[:advertiser])
    redirect_to admin_advertisers_path, :flash => { :success => I18n.t("advertiser.updated.success") }
  end

  def edit
    @advertiser = Advertiser.find(params[:id])
  end

  def new
    @advertiser = Advertiser.new
    @advertiser.user = User.new
  end

  def create
    @advertiser = Advertiser.new(params[:advertiser].except(:user))
    @advertiser.user = User.new(params[:advertiser][:user_attributes])
    if @advertiser.save
      redirect_to advertiser_root_path, :notice => "advertiser.created.success"
    else
      flash[:error] = I18n.t("advertiser.creation.error")
      render :action => "new"
    end
  end

  def login_as_advertiser
    adv = Advertiser.find(params[:advertiser_id])
    result = UserSession.create(adv.user)
    if result.errors.blank?
      flash[:success] = I18n.t("login.successful")
      redirect_to advertiser_root_path
    else
      flash[:error] = I18n.t("login.failed")
      logger.debug("ERROR: admin tries to login as advertiser; message: #{result.errors.inspect}")
      @advertisers = Advertiser.all
      render :action => :index
    end
  end

  def remove_advertiser
    adv = Advertiser.find(params[:advertiser_id])
    if adv.user.role?(User::ADMIN)
      adv.user.remove_role User::PUBLISHER
      adv.delete
      flash[:success] = I18n.t("advertiser.destroy.success")
    else
      delete_advertiser_without_history(adv)
    end
    redirect_to admin_advertisers_path
  end

  private

  def delete_advertiser_without_history adv
    if adv.has_history
      flash[:error] = I18n.t("advertiser.destroy.with_campaigns")
    else
      adv.destroy
      flash[:success] = I18n.t("advertiser.destroy.success")
    end
  end

end
