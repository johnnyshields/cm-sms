require 'spec_helper'
require 'cm_sms/message'

RSpec.describe CmSms::Message do
  before { allow(CmSms.config).to receive(:product_token).and_return('GLOBAL_TOKEN') }
  let(:from) { 'ACME' }
  let(:to) { '+41 44 111 22 33' }
  let(:dcs) { nil }
  let(:message_body) { 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirood tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.' }
  let(:reference) { 'Ref:123' }
  let(:product_token) { nil }
  let(:endpoints) { nil }

  let(:message) do
    described_class.new(
      from: from,
      to: to,
      dcs: dcs,
      body: message_body,
      reference: reference,
      product_token: product_token,
      endpoints: endpoints
    )
  end

  describe '#dcs' do
    context 'when dcs not set and message is GSM-compatible' do
      it { expect(message.dcs).to eq 0 }
    end

    context 'when dcs not set and message not GSM-compatible' do
      let(:message_body) { 'どうもありがとうミスターロボット。' }
      it { expect(message.dcs).to eq 8 }
    end

    context 'when dcs is provided as number' do
      let(:dcs) { 8 }
      it { expect(message.dcs).to eq 8 }
    end

    context 'when dcs is provided not as number' do
      let(:dcs) { 'foo' }
      it { expect { message }.to raise_error(ArgumentError) }
    end
  end

  describe '#receiver_plausible?' do
    context 'when a valid phone number is provided' do
      xit { expect(message.receiver_plausible?).to be true }
    end

    context 'phony present' do
      context 'when a invalid phone number is provided' do
        subject(:resource) do
          message.to = 'Fuubar'
          message
        end
        xit { expect(resource.receiver_plausible?).to be false }
      end
    end

    context 'phonelib present' do
      before { hide_const('Phony') }
      context 'when a invalid phone number is provided' do
        subject(:resource) do
          message.to = 'Fuubar'
          message
        end
        xit { expect(resource.receiver_plausible?).to be false }
      end
    end

    context 'neither phony nor phonelib present' do
      before do
        hide_const('Phony')
        hide_const('Phonelib')
      end
      context 'when a invalid phone number is provided' do
        subject(:resource) do
          message.to = 'Fuubar'
          message
        end
        xit { expect(resource.receiver_plausible?).to be true }
      end
    end
  end

  describe '#receiver_present?' do
    context 'when a valid phone number is provided' do
      xit { expect(message.receiver_present?).to be true }
    end

    context 'when no phone number is provided' do
      subject(:resource) do
        message.to = nil
        message
      end
      xit { expect(resource.receiver_present?).to be false }
    end
  end

  describe '#from' do
    context 'when a valid from is provided' do
      it { expect(message.from).to eq 'ACME' }
    end

    context 'when a valid from is provided' do
      let(:from) { 'ThisIsTooLong' }
      it { expect { message }.to raise_error(ArgumentError) }
    end

    context 'when no from is provided' do
      let(:from) { nil }
      it { expect { message }.to raise_error(ArgumentError) }
    end
  end

  describe '#body_present?' do
    context 'when a valid body is provided' do
      xit { expect(message.body_present?).to be true }
    end

    context 'when no body is provided' do
      subject(:resource) do
        message.body = nil
        message
      end
      xit { expect(resource.body_present?).to be false }
    end
  end

  describe '#endpoints' do
    context 'when a endpoints configured at config level' do
      before { CmSms.configure { |config| config.endpoints = %w[bazqux bingbaz] } }
      it { expect(message.endpoints).to eq %w[bazqux bingbaz] }

      context 'when a endpoints set on message' do
        let(:endpoints) { 'foobar' }
        it { expect(message.endpoints).to eq ['foobar'] }
      end
    end

    context 'when no endpoints is provided' do
      before { CmSms.configure { |config| config.endpoints = nil } }
      it { expect(message.endpoints).to eq %w[https://gw.cmtelecom.com] }

      context 'when a endpoints set on message' do
        let(:endpoints) { 'foobar' }
        it { expect(message.endpoints).to eq ['foobar'] }
      end
    end
  end

  describe '#product_token and #product_token_present?' do
    context 'when a product_token configured at config level' do
      before { CmSms.configure { |config| config.product_token = 'SOMETOKEN' } }
      xit { expect(message.product_token).to eq 'SOMETOKEN' }
      xit { expect(message.product_token_present?).to eq true }

      context 'when a product_token set on message' do
        let(:product_token) { 'MSGTOKEN' }
        xit { expect(message.product_token).to eq 'MSGTOKEN' }
        xit { expect(message.product_token_present?).to eq true }
      end
    end

    context 'when no product_token is provided' do
      before { CmSms.configure { |config| config.product_token = nil } }
      xit { expect(message.product_token).to eq nil }
      xit { expect(message.product_token_present?).to eq false }

      context 'when a product_token set on message' do
        let(:product_token) { 'MSGTOKEN' }
        xit { expect(message.product_token).to eq 'MSGTOKEN' }
        xit { expect(message.product_token_present?).to eq true }
      end
    end

    context 'when no product_token is blank' do
      before { CmSms.configure { |config| config.product_token = '' } }
      xit { expect(message.product_token).to eq '' }
      xit { expect(message.product_token_present?).to eq false }
    end
  end

  describe '#deliver' do
    context 'when all needed attributes set' do
      before do
        CmSms.configure { |config| config.product_token = 'SOMETOKEN' }
        request = instance_double(CmSms::Request)
        allow(request).to receive(:perform).and_return(true)
        allow(message).to receive(:request).and_return(request)
      end

      it { expect(message.deliver).to be true }
    end
  end

  describe '#request' do
    before { CmSms.configure { |config| config.endpoints = nil } }

    it { expect(message.request).to be_kind_of(CmSms::Request) }

    it do
      expect(CmSms::Request).to receive(:new).with(message.payload, %w[https://gw.cmtelecom.com])
      message.request
    end

    context 'when endpoints set' do
      let(:endpoints) { 'foobar' }
      it do
        expect(CmSms::Request).to receive(:new).with(message.payload, %w[foobar])
        message.request
      end
    end
  end

  # TODO: need specs for message payload class
  # describe '#to_xml' do
  #   before { CmSms.configure { |config| config.product_token = 'SOMETOKEN' } }
  #
  #   context 'when all attributes set' do
  #     let(:xml_body) { '<?xml version="1.0" encoding="UTF-8"?><MESSAGES><AUTHENTICATION><PRODUCTTOKEN>SOMETOKEN</PRODUCTTOKEN></AUTHENTICATION><MSG><FROM>ACME</FROM><TO>+41 44 111 22 33</TO><BODY>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirood tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At v</BODY><REFERENCE>Ref:123</REFERENCE></MSG></MESSAGES>' }
  #     xit { expect(message.to_xml).to eq xml_body }
  #   end
  #
  #   context 'when reference is missing' do
  #     subject(:resource) do
  #       message.reference = nil
  #       message
  #     end
  #     let(:xml_body) { '<?xml version="1.0" encoding="UTF-8"?><MESSAGES><AUTHENTICATION><PRODUCTTOKEN>SOMETOKEN</PRODUCTTOKEN></AUTHENTICATION><MSG><FROM>ACME</FROM><TO>+41 44 111 22 33</TO><BODY>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirood tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At v</BODY></MSG></MESSAGES>' }
  #     xit { expect(resource.to_xml).to eq xml_body }
  #   end
  # end
  #
  # TODO: MessageValidator spec
  # context 'when product token is missing in configuration' do
  #   before { CmSms.configure { |config| config.product_token = nil } }
  #   it { expect { message }.to raise_error ArgumentError }
  # end
  #
  # context 'when product token is given' do
  #   before { CmSms.configure { |config| config.product_token = 'SOMETOKEN' } }
  #
  #   context 'when receiver is missing' do
  #     subject(:resource) do
  #       message.to = nil
  #       message
  #     end
  #     it { expect { resource.deliver }.to raise_error CmSms::Message::ToMissing }
  #   end
  #
  #   context 'when sender is missing' do
  #     subject(:resource) do
  #       message.from = nil
  #       message
  #     end
  #     it { expect { resource.deliver }.to raise_error CmSms::Message::FromMissing }
  #   end
  #
  #   context 'when body is missing' do
  #     subject(:resource) do
  #       message.body = nil
  #       message
  #     end
  #     xit { expect { resource.deliver! }.to raise_error CmSms::Message::BodyMissing }
  #   end
  #
  #   context 'when body is to long' do
  #     subject(:resource) do
  #       message.body = [message.body, message.body].join # 2 x 160 signs
  #       message
  #     end
  #     xit { expect { resource.deliver! }.to raise_error CmSms::Message::BodyTooLong }
  #   end
  #
  #   context 'when to is not plausibe' do
  #     subject(:resource) do
  #       message.to = 'fuubar'
  #       message
  #     end
  #     xit { expect { resource.deliver! }.to raise_error CmSms::Message::ToUnplausible }
  #   end
  #
  #   context 'when dcs is not a number' do
  #     subject(:resource) do
  #       message.dcs = 'fuubar'
  #       message
  #     end
  #     xit { expect { resource.deliver! }.to raise_error CmSms::Message::DCSNotNumeric }
  #   end
  # end
end
