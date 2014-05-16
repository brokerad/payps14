require 'spec_helper'

describe "tracking_urls/show" do
  before(:each) do
    @tracking_url = assign(:tracking_url, stub_model(TrackingUrl))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
