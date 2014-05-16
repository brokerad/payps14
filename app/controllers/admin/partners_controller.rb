class Admin::PartnersController < Admin::ApplicationController
  def index
    @partners = Partner.includes(:coupons, :revenue_shares)
  end

  def new
    @partner = Partner.new
    @partner.user = User.new
  end

  def edit
    @partner = Partner.find(params[:id])
    @partner.user ||= User.new
  end

  def create
    @partner = Partner.new(params[:partner])
    @partner.user.role = User::PARTNER
    if @partner.save
      redirect_to(admin_partners_url, :notice => 'Partner was successfully created.')
    else
      render :new
    end
  end

  def update
    @partner = Partner.find(params[:id])
    @partner.attributes = params[:partner]
    @partner.user.add_role(User::PARTNER)
    if @partner.save
      redirect_to(admin_partners_url, :notice => 'Partner was successfully updated.')
    else
      render :new
    end
  end

  def destroy
    @partner = Partner.find(params[:id])
    @partner.destroy
    redirect_to(admin_partners_url)
  end

  def login_as_partner
    partner = Partner.find(params[:partner_id])
    result = UserSession.create(partner.user)
    if result.errors.blank?
      flash[:success] = I18n.t("login.successful")
      redirect_to partner_root_path
    else
      flash[:error] = I18n.t("login.failed")
      logger.debug("ERROR: admin tries to login as partner; message: #{result.errors.inspect}")
      @partners = Partner.includes(:coupons, :revenue_shares)
      render :action => :index
    end
  end
end
