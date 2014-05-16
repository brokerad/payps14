class Admin::PlacesController < Admin::ApplicationController
  def update
    @place = Place.find(params[:id])
    @place.update_attributes(params[:place])
  end
end
