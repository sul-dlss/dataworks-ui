# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackMailerParser do
  subject(:parser) { described_class.new(params, '127.0.0.1') }

  describe 'reading fields' do
    let(:params) do
      { name: 'Ada', to: 'ada@example.com', message: 'Hello', url: 'http://test.host/catalog',
        user_agent: 'Mozilla/5.0', viewport: 'width:1280 height:1024', last_search: 'maps' }
    end
    let(:expected) do
      { name: 'Ada', email: 'ada@example.com', message: 'Hello', url: 'http://test.host/catalog',
        user_agent: 'Mozilla/5.0', viewport: 'width:1280 height:1024', last_search: 'maps' }
    end

    it 'exposes the submitted values' do
      expect(parser).to have_attributes(expected)
    end
  end

  describe 'defaults for missing fields' do
    let(:params) { {} }

    it 'falls back for name and email' do
      expect(parser.name).to eq('No name given')
      expect(parser.email).to eq('No email given')
    end
  end

  describe 'BINARY (ASCII-8BIT) values' do
    let(:params) { { url: "http://test.host/\xC3".dup.force_encoding('ASCII-8BIT') } }

    it 'coerces them to a valid UTF-8 string' do
      expect(parser.url.encoding).to eq(Encoding::UTF_8)
      expect(parser.url).to be_valid_encoding
    end

    it 'can be rendered into a UTF-8 buffer without raising' do
      expect { +'Message sent from: ' << parser.url }.not_to raise_error
    end
  end
end
