require 'spec_helper'
require 'webmock/rspec'

RSpec.describe 'deliver sms' do
  before do
    CmSms.configure do |config|
      config.product_token = 'SOMETOKEN'
      config.endpoint = 'http://test.host'
      config.path = '/example'
    end

    stub_request(:post, 'http://test.host/example').
        with(body: "{\"messages\":{\"authentication\":{\"productToken\":\"SOMETOKEN\"},\"msg\":[{\"body\":{\"content\":\"lorem ipsum\"},\"to\":[{\"number\":\"+41 44 111 22 33\"}],\"from\":\"Sender\",\"dcs\":0,\"minimumNumberOfMessageParts\":1,\"maximumNumberOfMessageParts\":1,\"reference\":\"Ref:123\"}]}}",
             headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: "{\n  \"details\": \"Created 3 message(s)\",\n  \"errorCode\": 0,\n  \"messages\": [\n    {\n      \"to\": \"0041441112233\",\n      \"status\": \"Accepted\",\n      \"reference\": null,\n      \"parts\": 3,\n      \"messageDetails\": null,\n      \"messageErrorCode\": 0\n    }\n  ]\n}")
  end

  let (:message) do
    CmSms::Message.new(from: 'Sender',
                       to: '+41 44 111 22 33',
                       body: 'lorem ipsum',
                       reference: 'Ref:123')
  end

  subject { message.deliver }

  it { expect(subject.success?).to be true }
end
