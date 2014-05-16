class Admin::UsersController < Admin::ApplicationController
  def index
    @users = User.where('role !=?', 'publisher')
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create    
    @user = User.new(params[:user])
    @user.role = 'admin'
    @user.enabled = true
    
    if unpromoted_user = User.find_by_email(@user.email)
      unpromoted_user.update_attributes(params[:user])
      unpromoted_user.add_role(User::ADMIN) unless unpromoted_user.role?(User::ADMIN)
      if unpromoted_user.save
        redirect_to(admin_users_path, :notice => 'User was successfully promoted to admin.')
      else
        render :action => "new"
      end
    else
      if @user.save
        redirect_to(admin_users_path, :notice => 'User was successfully created.')
      else
        render :action => "new"
      end
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to(edit_admin_user_path(@user), :notice => 'User was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.roles.count > 1
      @user.remove_role(User::ADMIN)
    else
        #@user.destroy
    end 
    redirect_to(admin_users_url)
  end
end
