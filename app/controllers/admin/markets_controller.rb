class Admin::MarketsController < Admin::ApplicationController
  def index
    @markets = Market.all
  end

  def new
    @market = Market.new
  end

  def edit
    @market = Market.find(params[:id])
  end

  def create
    @market = Market.new(params[:market])
    if @market.save
      redirect_to(edit_admin_market_path(@market), :notice => 'Market was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @market = Market.find(params[:id])
    if @market.update_attributes(params[:market])
      redirect_to(edit_admin_market_path(@market), :notice => 'Market was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @market = Market.find(params[:id])
    @market.destroy
    redirect_to(admin_markets_url)
  end
end
