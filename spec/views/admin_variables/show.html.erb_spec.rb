require 'spec_helper'

describe "admin_variables/show" do
  before(:each) do
    @admin_variable = assign(:admin_variable, stub_model(AdminVariable,
      :key => "Key",
      :value => "Value"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Key/)
    rendered.should match(/Value/)
  end
end
