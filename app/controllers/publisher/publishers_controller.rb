class Publisher::PublishersController < Publisher::ApplicationController
  before_filter :require_user, :load_associations

  def edit
    @publisher = current_publisher
  end

  def update
    @publisher = current_publisher
    if @publisher.update_attributes(params[:publisher])
      update_places(params["places"], @publisher)

      redirect_to publisher_publisher_path(@publisher), :flash => { :success => I18n.t("publisher.updated.success") }
    else
      @publisher.errors.full_messages.each do |msg|
        flash.now[:error] ? flash.now[:error] += "<br/>#{msg}" : flash.now[:error] = msg
      end
      render :edit
    end
  end

  def show
    @publisher = current_publisher
  end

  private

  def load_associations
    @markets = Market.all
    @languages = Language.all
  end

  def update_places(places, publisher)
    disabled_places = []

    places.each do |p|
      Place.find(p.to_i).update_attributes(:enabled => true)
    end

    disabled_places = publisher.places.reject{|place| places.include?(place.id.to_s)}
    disabled_places.each do |p|
      Place.find(p.id).update_attributes(:enabled => false)
    end
  end
end
