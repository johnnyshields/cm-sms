require 'cm_sms/response'

module CmSms
  class Request
    attr_reader :response

    def initialize(payload, endpoints = nil)
      @payload = payload
      @endpoint = (endpoints || CmSms.config.endpoints).sample
    end

    def perform
      ::Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', open_timeout: timeout, read_timeout: timeout) do |http|
        @response = Response.new(http.post(path, @payload.to_json, headers))
      end
      response
    end

    private

    def uri
      @uri ||= ::URI.parse(@endpoint)
    end

    def path
      CmSms.config.path
    end

    def timeout
      CmSms.config.timeout
    end

    def headers
      { 'Accept' => 'application/json',
        'Content-Type' => 'application/json' }
    end
  end
end
