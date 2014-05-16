class Admin::CategoriesController < Admin::ApplicationController
  def index
    @category = Category.all
  end

  def new
    @category = Category.new
  end

  def edit
    @category = Category.find(params[:id])
  end

  def show
    @category = Category.find(params[:id])
  end

  def create
    @category = Category.new(params[:category])

    respond_to do |format|
      if @category.save
        format.html { redirect_to(admin_categories_path) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @category = Category.find(params[:id])

    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html { redirect_to(admin_categories_path) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def activate
    @category = Category.find(params[:id])

    @category.active = ! @category.active
    @category.save

    redirect_to(admin_categories_path)
  end

end

