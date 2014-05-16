require 'spec_helper'

describe Admin::AdvertisersHelper do
  it "should return enabled button" do
    advertiser_enabled = Factory(:advertiser)
    advertiser_enabled.user.enabled = true
    advertiser_enabled.save
    button = enable_button(advertiser_enabled)
    button.should eq("<a href=\"/admin/advertisers/#{advertiser_enabled.id}?advertiser[user_attributes][enabled]=false&amp;advertiser[user_attributes][id]=#{advertiser_enabled.user.id}\" class=\"btn\" data-method=\"put\" rel=\"nofollow\">Disable</a>")
  end
  it "should return disabled button" do
    advertiser_disabled = Factory(:advertiser)
    advertiser_disabled.user.enabled = false
    advertiser_disabled.save
    button = enable_button(advertiser_disabled)
    button.should eq("<a href=\"/admin/advertisers/#{advertiser_disabled.id}?advertiser[user_attributes][enabled]=true&amp;advertiser[user_attributes][id]=#{advertiser_disabled.user.id}\" class=\"btn success\" data-method=\"put\" rel=\"nofollow\">Enable</a>")
  end
end
