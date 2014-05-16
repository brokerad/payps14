require "spec_helper"

describe Admin::PublishersHelper do
  it "should return enabled button" do
    publisher_enabled = Publisher.new
    publisher_enabled.stub!(:id).and_return(666)
    publisher_enabled.stub!(:enabled).and_return(true)
    button = enable_publisher_button(publisher_enabled.id, publisher_enabled.enabled)
    button.should eq("<a href=\"/admin/publishers/#{publisher_enabled.id}?publisher[enabled]=false\" class=\"btn \" data-method=\"put\" rel=\"nofollow\">Disable</a>")
  end
  it "should return disabled button" do
    publisher_disabled = Publisher.new
    publisher_disabled.stub(:id).and_return(666)
    publisher_disabled.stub(:enabled).and_return(false)
    button = enable_publisher_button(publisher_disabled.id, publisher_disabled.enabled)
    button.should eq("<a href=\"/admin/publishers/#{publisher_disabled.id}?publisher[enabled]=true\" class=\"btn success\" data-method=\"put\" rel=\"nofollow\">Enable</a>")
  end
end
