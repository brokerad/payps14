class Admin::LanguagesController < Admin::ApplicationController
  def index
    @languages = Language.all
  end

  def new
    @language = Language.new
  end

  def edit
    @language = Language.find(params[:id])
  end

  def create
    @language = Language.new(params[:language])
    if @language.save
      redirect_to(edit_admin_language_path(@language), :notice => 'Language was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @language = Language.find(params[:id])
    if @language.update_attributes(params[:language])
      redirect_to(edit_admin_language_path(@language), :notice => 'Language was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @language = Language.find(params[:id])
    @language.destroy
    redirect_to(admin_languages_url)
  end
end
