class Admin::BannersController < Admin::ApplicationController
  def index
    @banners = Banner.all
  end

  def show
    @banner = Banner.find(params[:id])
  end

  def new
    @banner = Banner.new    
  end

  def edit
    @banner = Banner.find(params[:id])
  end

  def create
    @banner = Banner.new(params[:banner])
    if @banner.save
      redirect_to(admin_banners_path, :notice => 'Banner was successfully created.') 
    else
      render :action => "new" 
    end
  end

  def update
    @banner = Banner.find(params[:id])
    if @banner.update_attributes(params[:banner])
      redirect_to(admin_banners_path, :notice => 'Banner was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @banner = Banner.find(params[:id])
    @banner.destroy
    redirect_to(admin_banners_path)
  end
end
