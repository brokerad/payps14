require 'spec_helper'

describe Publisher::RequestPaymentsController do
  render_views

  login_publisher

  describe "publisher" do
    it "should redirect to profile if no billing data" do
      pending "Add places in publisher factory"
      # @publisher.stub!(:ready_for_billing?).and_return(false)
      # get "index"
      # response.should redirect_to("/publisher/publishers/#{@publisher.id}")
    end

    it "should redirect to profile if no billing data" do
      pending "Add places in publisher factory"
      # @publisher.stub!(:ready_for_billing?).and_return(true)
      # get "index"
      # response.should render_template("index")
    end
  end
end
