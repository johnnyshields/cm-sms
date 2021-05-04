module CmSms
  class Configuration
    ENDPOINTS = %w[https://gw.cmtelecom.com].map(&:freeze).freeze
    PATH = '/v1.0/message'.freeze
    TIMEOUT = 10

    attr_accessor :from,
                  :dcs,
                  :product_token

    attr_writer :endpoints,
                :path,
                :timeout

    alias api_key= product_token=
    alias endpoint= endpoints=

    def endpoints
      endpoints = Array(@endpoints)
      endpoints.empty? ? ENDPOINTS : endpoints
    end

    def path
      @path || PATH
    end

    def timeout
      @timeout || TIMEOUT
    end
  end
end
