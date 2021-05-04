module CmSms
  class Response
    attr_reader :net_http_response,
                :body,
                :code

    def initialize(net_http_response)
      @net_http_response = net_http_response
      @code = @net_http_response.code
      @body = JSON.parse(@net_http_response.body) rescue @net_http_response.body
    end

    def success?
      code.to_i == 200
    end

    def failure?
      !success?
    end

    def error
      return unless body.is_a?(Hash)
      body.dig('messages', 0, 'messageDetails')
    end
  end
end
