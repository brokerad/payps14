class Admin::VariablesController < Admin::ApplicationController

  def index
    @admin_variables = AdminVariable.all
    @editable = true
  end

  def edit
    @admin_variable = AdminVariable.find(params[:id])
    @editable = false
  end

  def update
    @admin_variable = AdminVariable.find(params[:id])

    respond_to do |format|
      if @admin_variable.update_attributes(:value => params[:admin_variable][:value])
        format.html { redirect_to(admin_variables_path, :notice => 'Admin variable was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

end
