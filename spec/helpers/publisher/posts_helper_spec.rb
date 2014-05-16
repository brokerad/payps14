require "spec_helper"

describe Publisher::PostsHelper do
  it "should initialize a new post" do
    campaign = Factory(:active_campaign)
    ad = Factory(:ad, :campaign => campaign)
    place = Factory(:place)
    post = find_or_initialize_post ad, place
    post.new_record?.should be_true
  end

  it "should return a persisted post" do
    campaign = Factory(:active_campaign)
    ad = Factory(:ad, :campaign => campaign)
    place = Factory(:place)
    post = find_or_initialize_post ad, place
    post.new_record?.should be_true
  end
end
