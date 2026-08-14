# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Feedback::WithReferer do
  subject(:referer) { includer.referer }

  let(:includer) do
    Class.new do
      include Feedback::WithReferer

      def initialize(request)
        @request = request
      end

      attr_reader :request
    end.new(request)
  end

  let(:request) { instance_double(ActionDispatch::Request, referer: header) }

  context 'when there is no referer' do
    let(:header) { nil }

    it { is_expected.to be_nil }
  end

  context 'when the referer is blank' do
    let(:header) { '' }

    it { is_expected.to be_nil }
  end

  context 'with a plain UTF-8 referer' do
    let(:header) { 'http://localhost:3000/catalog' }

    it { is_expected.to eq('http://localhost:3000/catalog') }
  end

  context 'with a BINARY (ASCII-8BIT) referer containing invalid bytes' do
    let(:header) { "http://localhost:3000/\xC3".dup.force_encoding('ASCII-8BIT') }

    it 'returns a valid UTF-8 string' do
      expect(referer.encoding).to eq(Encoding::UTF_8)
      expect(referer).to be_valid_encoding
    end

    it 'can be concatenated onto a UTF-8 buffer without raising' do
      expect { +'ok' << referer }.not_to raise_error
    end
  end
end
