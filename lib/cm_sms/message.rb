require 'gsm_encoder'
require 'cm_sms/multipart_calculator'
require 'cm_sms/message_validator'
require 'cm_sms/request_payload'
require 'cm_sms/request'

module CmSms
  class Message
    DCS_GSM = 0
    DCS_UCS2 = 8

    attr_reader :from,
                :to,
                :body,
                :dcs,
                :reference,
                :min_parts,
                :max_parts,
                :product_token,
                :endpoints

    def initialize(attributes = {})
      @product_token = attributes[:product_token] || CmSms.config.product_token
      @endpoints     = attributes[:endpoints] ? Array(attributes[:endpoints]) : CmSms.config.endpoints
      @from          = attributes[:from] || CmSms.config.from
      @to            = attributes[:to]
      @body          = attributes[:body]
      MessageValidator.new(@product_token, @from, @to, @body).validate!
      @reference     = attributes[:reference]
      @dcs           = attributes[:dcs] ? Integer(attributes[:dcs]) : CmSms.config.dcs || detect_dcs
      @min_parts     = attributes[:min_parts] ? Integer(attributes[:min_parts]) : 1
      @max_parts     = attributes[:max_parts] ? Integer(attributes[:max_parts]) : detect_num_parts
    end

    def deliver
      request.perform
    end

    def payload
      RequestPayload.new(self).payload
    end

    def request
      Request.new(payload, endpoints)
    end

    private

    def detect_dcs
      GSMEncoder.can_encode?(body) ? DCS_GSM : DCS_UCS2
    end

    def detect_num_parts
      MultipartCalculator.new(body, dcs == DCS_GSM).num_parts
    end
  end
end
