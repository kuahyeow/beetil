require 'spec_helper'

describe Beetil::Change do
  before do
    WebMock.disable_net_connect!
  end
  after do
    WebMock.allow_net_connect!
    WebMock.reset!
  end

  before do
    Beetil.configure do |config|
      config.api_token = "some_token"
    end
  end

  describe "find" do
    it "should get the right url" do
      stub = stub_request(:get, "https://x:some_token@deskapi.gotoassist.com/v1/changes/1")
      Beetil::Change.find(1)
      stub.should have_been_requested
    end

    it "should not error out if the beetil number was incorect" do
        stub_request(:get, "https://x:some_token@deskapi.gotoassist.com/v1/changes/1").to_return(
          :body => '{"version":"1.0", "errors":[{"error":"[E400] no change found"}], "status":"Failed"}'
        )
      expect do
        Beetil::Change.find(1)
      end.to_not raise_error
    end
  end
end
