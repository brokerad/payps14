require "spec_helper"

describe AdminVariablesController do
  describe "routing" do

    it "routes to #index" do
      get("/admin_variables").should route_to("admin_variables#index")
    end

    it "routes to #new" do
      get("/admin_variables/new").should route_to("admin_variables#new")
    end

    it "routes to #show" do
      get("/admin_variables/1").should route_to("admin_variables#show", :id => "1")
    end

    it "routes to #edit" do
      get("/admin_variables/1/edit").should route_to("admin_variables#edit", :id => "1")
    end

    it "routes to #create" do
      post("/admin_variables").should route_to("admin_variables#create")
    end

    it "routes to #update" do
      put("/admin_variables/1").should route_to("admin_variables#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin_variables/1").should route_to("admin_variables#destroy", :id => "1")
    end

  end
end
