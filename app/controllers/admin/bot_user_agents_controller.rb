require 'mustache'

class Admin::BotUserAgentsController < Admin::ApplicationController
  
  def index
    @user_agents = BotUserAgent.order('updated_at DESC')
  end

  def new
    @user_agent = BotUserAgent.new
  end

  def edit
    @user_agent = BotUserAgent.find(params[:id])
  end
 
  def create
    @user_agent = BotUserAgent.new(params[:bot_user_agent])
    if @user_agent.save
      redirect_to(admin_bot_user_agents_path, :notice => 'User Agent was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @user_agent = BotUserAgent.find(params[:id])
    if @user_agent.update_attributes(params[:bot_user_agent])
      redirect_to(admin_bot_user_agents_path, :notice => "User Agent was successfully updated.")
    else
      render :action => "edit"
    end
  end

  def destroy
    @user_agent = BotUserAgent.find(params[:id])
    @user_agent.destroy
    redirect_to(admin_bot_user_agents_path)
  end
end
