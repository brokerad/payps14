require 'spec_helper'

describe "admin_variables/index" do
  before(:each) do
    assign(:admin_variables, [
      stub_model(AdminVariable,
        :key => "Key",
        :value => "Value"
      ),
      stub_model(AdminVariable,
        :key => "Key",
        :value => "Value"
      )
    ])
  end

  it "renders a list of admin_variables" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Key".to_s, :count => 2
    assert_select "tr>td", :text => "Value".to_s, :count => 2
  end
end
