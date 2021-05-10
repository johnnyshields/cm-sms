require 'gsm_encoder'

module CmSms
  class MultipartCalculator
    PART_LENGTHS_GSM = [160, 153].freeze
    PART_LENGTHS_UCS2 = [70, 67].freeze

    attr_reader :body, :gsm

    def initialize(body, gsm)
      @body = body
      @gsm = gsm
    end

    def num_parts
      if gsm
        part_lengths = PART_LENGTHS_GSM
        body_length = GSMEncoder.encode(body).length
      else
        part_lengths = PART_LENGTHS_UCS2
        body_length = body.length
      end

      if body_length <= part_lengths[0]
        1
      else
        [(body_length.to_f / part_lengths[1]).ceil, 1].max
      end
    end
  end
end
