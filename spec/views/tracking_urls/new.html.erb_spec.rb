require 'spec_helper'

describe "tracking_urls/new" do
  before(:each) do
    assign(:tracking_url, stub_model(TrackingUrl).as_new_record)
  end

  it "renders new tracking_url form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => tracking_urls_path, :method => "post" do
    end
  end
end
