require "spec_helper"

describe Admin::TrackingUrlsController do
  describe "routing" do

    it "routes to #index" do
      get("/admin/tracking_urls").should route_to("admin/tracking_urls#index")
    end

    it "routes to #new" do
      get("/admin/tracking_urls/new").should route_to("admin/tracking_urls#new")
    end

    it "routes to #show" do
      get("/admin/tracking_urls/1").should route_to("admin/tracking_urls#show", :id => "1")
    end

    it "routes to #edit" do
      get("/admin/tracking_urls/1/edit").should route_to("admin/tracking_urls#edit", :id => "1")
    end

    it "routes to #create" do
      post("/admin/tracking_urls").should route_to("admin/tracking_urls#create")
    end

    it "routes to #update" do
      put("/admin/tracking_urls/1").should route_to("admin/tracking_urls#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/tracking_urls/1").should route_to("admin/tracking_urls#destroy", :id => "1")
    end

  end
end
