class Partner::EditController < Partner::ApplicationController
  
  def edit
    @partner = current_partner
  end

  def update
    @partner = current_partner
    @partner.attributes = params[:partner]
    if @partner.save
      flash[:success] = I18n.t("publisher.updated.success")
      redirect_to partner_dashboard_path
    else
      render :edit
    end
  end

end