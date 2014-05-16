require 'spec_helper'

describe "admin_variables/new" do
  before(:each) do
    assign(:admin_variable, stub_model(AdminVariable,
      :key => "MyString",
      :value => "MyString"
    ).as_new_record)
  end

  it "renders new admin_variable form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => admin_variables_path, :method => "post" do
      assert_select "input#admin_variable_key", :name => "admin_variable[key]"
      assert_select "input#admin_variable_value", :name => "admin_variable[value]"
    end
  end
end
