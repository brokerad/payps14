require "spec_helper"

describe EngageNotifier do
  describe "engage_complete" do

    current_publisher = Factory(:user_publisher)
    let(:mail) { EngageNotifier.engage_complete(current_publisher) }

    it "renders the headers" do
      mail.subject.should eq("Engage complete")
      mail.to.should eq([current_publisher.email])
      mail.from.should eq(["noreply@paypersocial.com"])
    end

#     it "renders the body" do
#       mail.body.encoded.should match("")
#     end
  end

  describe "new_publisher_jois_us" do
    current_publisher = Factory(:user_publisher)
    addresses = Array.new

    let(:mail) { EngageNotifier.new_publisher_joined_us(current_publisher) }

    File.open("config/admin_emails.txt", "r").each_line do |line|
      address = line.split(/\n/)[0]
      addresses.push address unless (address.first == '#' or address.first.empty?)
    end

    it "renders the headers" do
      mail.subject.should eq("New publisher joined us")
      mail.to.should eq(addresses)
      mail.from.should eq(["noreply@paypersocial.com"])
    end

  end
end

