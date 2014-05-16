class Tools::StatusController < ApplicationController
  layout false
  
  def index
    @memory = `free -mot`
  end
end