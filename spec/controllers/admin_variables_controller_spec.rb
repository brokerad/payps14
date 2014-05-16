require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe AdminVariablesController do

  # This should return the minimal set of attributes required to create a valid
  # AdminVariable. As you add validations to AdminVariable, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AdminVariablesController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all admin_variables as @admin_variables" do
      admin_variable = AdminVariable.create! valid_attributes
      get :index, {}, valid_session
      assigns(:admin_variables).should eq([admin_variable])
    end
  end

  describe "GET show" do
    it "assigns the requested admin_variable as @admin_variable" do
      admin_variable = AdminVariable.create! valid_attributes
      get :show, {:id => admin_variable.to_param}, valid_session
      assigns(:admin_variable).should eq(admin_variable)
    end
  end

  describe "GET new" do
    it "assigns a new admin_variable as @admin_variable" do
      get :new, {}, valid_session
      assigns(:admin_variable).should be_a_new(AdminVariable)
    end
  end

  describe "GET edit" do
    it "assigns the requested admin_variable as @admin_variable" do
      admin_variable = AdminVariable.create! valid_attributes
      get :edit, {:id => admin_variable.to_param}, valid_session
      assigns(:admin_variable).should eq(admin_variable)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new AdminVariable" do
        expect {
          post :create, {:admin_variable => valid_attributes}, valid_session
        }.to change(AdminVariable, :count).by(1)
      end

      it "assigns a newly created admin_variable as @admin_variable" do
        post :create, {:admin_variable => valid_attributes}, valid_session
        assigns(:admin_variable).should be_a(AdminVariable)
        assigns(:admin_variable).should be_persisted
      end

      it "redirects to the created admin_variable" do
        post :create, {:admin_variable => valid_attributes}, valid_session
        response.should redirect_to(AdminVariable.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved admin_variable as @admin_variable" do
        # Trigger the behavior that occurs when invalid params are submitted
        AdminVariable.any_instance.stub(:save).and_return(false)
        post :create, {:admin_variable => {}}, valid_session
        assigns(:admin_variable).should be_a_new(AdminVariable)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        AdminVariable.any_instance.stub(:save).and_return(false)
        post :create, {:admin_variable => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested admin_variable" do
        admin_variable = AdminVariable.create! valid_attributes
        # Assuming there are no other admin_variables in the database, this
        # specifies that the AdminVariable created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        AdminVariable.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => admin_variable.to_param, :admin_variable => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested admin_variable as @admin_variable" do
        admin_variable = AdminVariable.create! valid_attributes
        put :update, {:id => admin_variable.to_param, :admin_variable => valid_attributes}, valid_session
        assigns(:admin_variable).should eq(admin_variable)
      end

      it "redirects to the admin_variable" do
        admin_variable = AdminVariable.create! valid_attributes
        put :update, {:id => admin_variable.to_param, :admin_variable => valid_attributes}, valid_session
        response.should redirect_to(admin_variable)
      end
    end

    describe "with invalid params" do
      it "assigns the admin_variable as @admin_variable" do
        admin_variable = AdminVariable.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        AdminVariable.any_instance.stub(:save).and_return(false)
        put :update, {:id => admin_variable.to_param, :admin_variable => {}}, valid_session
        assigns(:admin_variable).should eq(admin_variable)
      end

      it "re-renders the 'edit' template" do
        admin_variable = AdminVariable.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        AdminVariable.any_instance.stub(:save).and_return(false)
        put :update, {:id => admin_variable.to_param, :admin_variable => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested admin_variable" do
      admin_variable = AdminVariable.create! valid_attributes
      expect {
        delete :destroy, {:id => admin_variable.to_param}, valid_session
      }.to change(AdminVariable, :count).by(-1)
    end

    it "redirects to the admin_variables list" do
      admin_variable = AdminVariable.create! valid_attributes
      delete :destroy, {:id => admin_variable.to_param}, valid_session
      response.should redirect_to(admin_variables_url)
    end
  end

end
