module CmSms
  class RequestPayload
    attr_reader :message

    def initialize(message)
      @message = message
    end

    def payload
      {
        messages: {
          authentication: { productToken: message.product_token },
          msg: [payload_message]
        }
      }
    end

    private

    def payload_message
      data = {
        body: { content: message.body },
        to: [{ number: message.to }],
        from: message.from,
        dcs: message.dcs,
        minimumNumberOfMessageParts: message.min_parts,
        maximumNumberOfMessageParts: message.max_parts
      }
      data[:reference] = message.reference if message.reference
      data
    end
  end
end
