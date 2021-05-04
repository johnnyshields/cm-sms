require 'spec_helper'
require 'cm_sms/request'

RSpec.describe CmSms::Request do
  let(:message_body) { 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirood tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At v' }
  let(:message) do
    CmSms::Message.new(
      product_token: 'TOKEN',
      from: 'ACME',
      to: '+41 44 111 22 33',
      body: message_body,
      reference: 'Ref:123'
    )
  end
  let(:endpoints) { nil }
  let(:request) { described_class.new(message.payload, endpoints) }

  describe '@endpoint' do
    before { CmSms.configuration.endpoints = nil }

    context 'endpoint is randomized to first' do
      before { srand(0) }
      it { expect(request.instance_variable_get('@endpoint')).to eq 'https://gw.cmtelecom.com' }
    end

    context 'endpoint is randomized to second' do
      before { srand(1) }
      it { expect(request.instance_variable_get('@endpoint')).to eq 'https://gw.cmtelecom.com' }
    end

    context 'when endpoints arg set' do
      let(:endpoints) { %w[foobar bazqux] }
      before { srand(0) }
      it { expect(request.instance_variable_get('@endpoint')).to eq 'foobar' }
    end
  end

  describe '#perform' do
    context 'when request was successful' do
      it 'return a instance CmSms::Response' do
        http_response = Net::HTTPOK.new('post', 200, 'found')
        http_response.content_type = 'application/json'
        allow(http_response).to receive(:body).and_return('')
        response = CmSms::Response.new(http_response)

        allow_any_instance_of(described_class).to receive(:perform).and_return(response)
        expect(request.perform.success?).to be true
      end
    end
  end
end
