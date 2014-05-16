class PlacesResetAcceessToken < ActiveRecord::Migration
  def self.up
    Place.where(:place_type => 'Account').update_all(:access_token => '')
  end

  def self.down
    #noop
  end
end
