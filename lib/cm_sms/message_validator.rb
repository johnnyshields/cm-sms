module CmSms
  class MessageValidator
    attr_reader :product_token,
                :from,
                :to,
                :body

    def initialize(product_token, from, to, body)
      @product_token = product_token
      @from = from
      @to = to
      @body = body
    end

    def validate!
      validate_presence_of(:product_token)
      validate_presence_of(:from)
      validate_presence_of(:to)
      validate_presence_of(:body)
      validate_length_of_from
      validate_plausibility_of_to
    end

    private

    def validate_presence_of(attribute)
      value = self.send(attribute)
      return unless value.nil? || value.empty?
      raise ArgumentError.new("Required attribute missing :#{attribute}")
    end

    def validate_length_of_from
      return if from.length <= 11
      raise ArgumentError.new(":from length must be between 1 and 11")
    end

    def validate_plausibility_of_to
      return if to_plausible?
      raise ArgumentError.new(":to not a plausible phone number #{to}")
    end

    def to_plausible?
      if defined?(Phony) && Phony.respond_to?(:plausible?)
        Phony.plausible?(to)
      elsif defined?(Phonelib) && Phonelib.respond_to?(:valid?)
        Phonelib.valid?(to)
      else
        true
      end
    end
  end
end
