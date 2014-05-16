require 'spec_helper'

describe UrlExistanceValidator do

  before(:each) do
    @validator = UrlExistanceValidator.new(nil)
    @ad = Ad.new
  end
  
  it "invalid url" do
    @ad.link = 'not.valid.url'
    @validator.validate(@ad)
    @ad.errors[:link][0].should eq I18n.t("ad.validate.url")
  end
  
  it "inexisting url" do
    @ad.link = 'http://paypersocial.opa.ght'
    @validator.validate(@ad)
    @ad.errors[:link][0].should eq I18n.t("ad.validate.url")
  end
  
  it "existing url" do
    @ad.link = 'http://google.com'
    @ad.picture_link = 'http://google.com'
    @validator.validate(@ad)
    @ad.errors.count.should eq 0
  end
  
end
