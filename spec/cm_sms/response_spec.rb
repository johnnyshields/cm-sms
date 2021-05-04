require 'spec_helper'
require 'cm_sms/response'

RSpec.describe CmSms::Response do
  let(:response) do
    http_response = Net::HTTPOK.new('post', 200, 'found')
    http_response.content_type = 'application/json'
    allow(http_response).to receive(:body).and_return('')
    described_class.new(http_response)
  end

  describe '#success?' do

    context 'when response is successful' do
      it { expect(response.success?).to be true }
    end

    context 'when response is failed' do
      subject(:resource) do
        http_response = Net::HTTPOK.new('post', 400, 'BAD_REQUEST')
        http_response.content_type = 'application/json'
        allow(http_response).to receive(:body).and_return("{\n  \"details\": \"Created 0 message(s)\",\n  \"errorCode\": 201,\n  \"messages\": [\n    {\n      \"to\": \"00818035195647\",\n      \"status\": \"Rejected\",\n      \"reference\": null,\n      \"parts\": 0,\n      \"messageDetails\": \"Maximum number of parts exceeded. (need at least 10, max is 1)\",\n      \"messageErrorCode\": 304\n    }\n  ]\n}")
        described_class.new(http_response)
      end

      it do
        expect(resource.success?).to be false
        expect(resource.failure?).to be true
        expect(resource.error).to eq 'Maximum number of parts exceeded. (need at least 10, max is 1)'
      end
    end
  end
end
