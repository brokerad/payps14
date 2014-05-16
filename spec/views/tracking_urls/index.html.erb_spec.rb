require 'spec_helper'

describe "tracking_urls/index" do
  before(:each) do
    assign(:tracking_urls, [
      stub_model(TrackingUrl),
      stub_model(TrackingUrl)
    ])
  end

  it "renders a list of tracking_urls" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
