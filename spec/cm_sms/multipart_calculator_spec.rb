require 'spec_helper'
require 'cm_sms/multipart_calculator'

RSpec.describe CmSms::MultipartCalculator do
  describe '#num_parts' do
    it 'gsm encoding' do
      [
        ['a' * 160, true, 1],
        ['a' * 161, true, 2],
        ['a' * 306, true, 2],
        ['a' * 307, true, 3],
        ['a' * 459, true, 3],
        ['a' * 460, true, 4],
        ['あ' * 160, true, 1],
        ['あ' * 161, true, 2]
      ].each do |body, gsm, exp|
        expect(described_class.new(body, gsm).num_parts).to eq exp
      end
    end

    it 'gsm extended chars' do
      [
        ['a€' * 53, true, 1],
        ['a€' * 54, true, 2]
      ].each do |body, gsm, exp|
        expect(described_class.new(body, gsm).num_parts).to eq exp
      end
    end

    it 'ucs2 encoding' do
      [
        ['あ' * 70, false, 1],
        ['あ' * 71, false, 2],
        ['あ' * 134, false, 2],
        ['あ' * 135, false, 3],
        ['あ' * 201, false, 3],
        ['あ' * 202, false, 4],
        ['a' * 70, false, 1],
        ['a' * 71, false, 2]
      ].each do |body, gsm, exp|
        expect(described_class.new(body, gsm).num_parts).to eq exp
      end
    end
  end
end
