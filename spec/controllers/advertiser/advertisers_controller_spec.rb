# coding: UTF-8

require 'spec_helper'

describe Advertiser::AdvertisersController do
  def valid_attributes
    attributes = Factory.attributes_for(:advertiser)
    attributes[:user_attributes] = Factory.attributes_for(:user_advertiser)
    attributes
  end

  describe "GET new" do
    it "assigns a new advertiser as @advertiser" do
      get :new
      assigns(:advertiser).should be_a_new(Advertiser)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Advertiser" do
        expect {
          post :create, :advertiser => valid_attributes
        }.to change(Advertiser, :count).by(1)
      end

      it "assigns a newly created advertiser as @advertiser" do
        post :create, :advertiser => valid_attributes
        assigns(:advertiser).should be_a(Advertiser)
        assigns(:advertiser).should be_persisted
      end

      it "should set ADVERTISER role to the user" do
        post :create, :advertiser => valid_attributes
        assigns(:advertiser).should be_a(Advertiser)
        assigns(:advertiser).should be_persisted
        assigns(:advertiser).user.role?(User::ADVERTISER).should be_true

      end

      it "redirects to the created advertiser" do
        post :create, :advertiser => valid_attributes
        response.should render_template("create")
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved advertiser as @advertiser" do
        # Trigger the behavior that occurs when invalid params are submitted
        Advertiser.any_instance.stub(:save).and_return(false)
        post :create, :advertiser => {}
        assigns(:advertiser).should be_a_new(Advertiser)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Advertiser.any_instance.stub(:save).and_return(false)
        post :create, :advertiser => {}
        response.should render_template("new")
      end
    end
  end
end
