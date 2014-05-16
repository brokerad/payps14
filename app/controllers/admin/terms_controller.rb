class Admin::TermsController  < Admin::ApplicationController
  def index
    @terms = Term.all
  end

  def new
    @term = Term.new
  end

  def edit
    @term = Term.find(params[:id])
  end

  def create
    @term = Term.new(params[:term])
    if @term.save
      redirect_to(admin_term_path(@term), :notice => 'Term was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @term = Term.find(params[:id])
    if @term.update_attributes(params[:term])
      redirect_to(admin_terms_path, :notice => I18n.t("term.updated.success"))
    else
      render :action => "edit"
    end
  end

  def destroy
    @term = Term.find(params[:id])
    @term.destroy
    redirect_to(admin_terms_url)
  end

  def show
    @term = Term.find(params[:id])
  end
end