class Admin::TrafficManagersController < Admin::ApplicationController
  def index
    @traffic_managers = User.where("role LIKE '%admin%'").order("id ASC")
  end
end
