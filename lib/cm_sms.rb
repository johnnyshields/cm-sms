require 'cm_sms/configuration'

module CmSms
  require 'json'
  require 'net/http'
  autoload :Message, 'cm_sms/message'
  autoload :Webhook, 'cm_sms/webhook'

  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration
  end
end
