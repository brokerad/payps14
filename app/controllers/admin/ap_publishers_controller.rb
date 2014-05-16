class Admin::ApPublishersController < Admin::ApplicationController
  def index
    @publishers = Publisher.unscoped.order(:first_name, :last_name).page params[:page]
  end

  def search
    @publishers = Publisher.search_by_keyword(params[:search]).page params[:page]
    render :index
  end
end
