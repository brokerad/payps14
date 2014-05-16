class Admin::PrepaidPackagesController < Admin::ApplicationController
  def index
    @prepaid_packages = PrepaidPackage.all
  end

  def new
    @prepaid_package = PrepaidPackage.new
  end

  def edit
    @prepaid_package = PrepaidPackage.find(params[:id])
  end

  def create
    @prepaid_package = PrepaidPackage.new(params[:prepaid_package])
    if @prepaid_package.save
      redirect_to(edit_admin_prepaid_package_path(@prepaid_package), :notice => 'PrepaidPackage was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @prepaid_package = PrepaidPackage.find(params[:id])
    if @prepaid_package.update_attributes(params[:prepaid_package])
      redirect_to(edit_admin_prepaid_package_path(@prepaid_package), :notice => 'PrepaidPackage was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @prepaid_package = PrepaidPackage.find(params[:id])
    @prepaid_package.destroy
    redirect_to(admin_prepaid_packages_url)
  end
end
