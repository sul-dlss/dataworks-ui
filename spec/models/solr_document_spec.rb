# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrDocument do
  describe '#url_host' do
    subject(:url_host) { described_class.new(url_ss: url).url_host }

    context 'with a valid URL' do
      let(:url) { 'https://example.com/datasets/abc-123' }

      it 'returns the host' do
        expect(url_host).to eq('example.com')
      end
    end

    context 'with an unparseable URL' do
      let(:url) { 'not a url' }

      it 'falls back to the raw value' do
        expect(url_host).to eq('not a url')
      end
    end

    context 'when the URL is blank' do
      let(:url) { nil }

      it 'returns nil' do
        expect(url_host).to be_nil
      end
    end
  end
end
