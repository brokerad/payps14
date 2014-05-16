require 'spec_helper'

describe "tracking_urls/edit" do
  before(:each) do
    @tracking_url = assign(:tracking_url, stub_model(TrackingUrl))
  end

  it "renders the edit tracking_url form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => tracking_urls_path(@tracking_url), :method => "post" do
    end
  end
end
