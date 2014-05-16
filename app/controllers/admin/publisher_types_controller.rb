class Admin::PublisherTypesController < Admin::ApplicationController
  def index
    @publisher_types = PublisherType.all
  end

  def new
    @publisher_type = PublisherType.new
  end

  def create
    @publisher_type = PublisherType.new(params[:publisher_type])
    if @publisher_type.save
      redirect_to(admin_publisher_types_path, :notice => t("publisher_type.created.success"))
    else
      flash.now[:error] = I18n.t("publisher_type.created.error")
      render :new
    end
  end

  def edit
    @publisher_type = PublisherType.find(params[:id])
  end

  def update
    @publisher_type = PublisherType.find(params[:id])
    if @publisher_type.update_attributes(params[:publisher_type])
      redirect_to admin_publisher_types_path, :notice => I18n.t("publisher_type.updated.success")
    else
      flash.now[:error] = I18n.t("publisher_type.updated.error")
      render :edit
    end
  end

  def destroy
    @publisher_type = PublisherType.find(params[:id])
    @publisher_type.destroy
    if @publisher_type.destroyed?
      flash[:success] = t("publisher_type.destroy.success")
    else
      flash[:error] = t("publisher_type.destroy.with_publishers")
    end
    redirect_to admin_publisher_types_path
  end
end
