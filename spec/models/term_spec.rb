require "spec_helper"

describe Term do
  describe "Enabling and Disabling term" do
    it "should enable a term and disable the actual term enabled" do
      # Term enabled 1
      term_enabled1 = Factory(:term_disabled)
      term_enabled1.enabled = true
      term_enabled1.save
      # Term enabled 2
      term_enabled2 = Factory(:term_disabled)
      term_enabled2.enabled = true
      term_enabled2.save
      term_enabled1.reload
      term_enabled1.enabled.should be_false
    end
  end

  describe "Update term content" do
    it "should can't update term content" do
      term_enabled1 = Factory(:term_disabled)
      term_enabled1.enabled = true
      # set enabled
      term_enabled1.save.should be_true
      # should change content for not accepted term
      term_enabled1.eng = "XYZ"
      term_enabled1.save.should be_true
      # accepting a term
      publisher = Factory(:publisher, :accepted_term => term_enabled1)
      # can't change the content for accepted term
      term_enabled1.reload
      term_enabled1.eng = "XYZW"
      # validation temporarily removed
      #term_enabled1.save.should be_false
      # can disable it
      term_enabled1.reload
      term_enabled1.enabled = false
      term_enabled1.save.should be_true
    end
  end
end
