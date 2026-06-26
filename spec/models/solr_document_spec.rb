# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrDocument do
  describe '#struct_field' do
    subject(:struct_field) { described_class.new(rights_list_struct_ss: value).struct_field('rights_list_struct_ss') }

    context 'with a JSON value' do
      let(:value) { [{ 'rights' => 'CC-BY' }].to_json }

      it 'parses it into Ruby data' do
        expect(struct_field).to eq([{ 'rights' => 'CC-BY' }])
      end
    end

    context 'when the field is blank' do
      let(:value) { nil }

      it 'returns an empty array' do
        expect(struct_field).to eq([])
      end
    end
  end

  describe '#contributors' do
    subject(:contributors) do
      described_class.new(creators_struct_ss: creators.to_json,
                          contributors_struct_ss: other_contributors.to_json).contributors
    end

    let(:creators) { [{ 'name' => 'Ada Lovelace' }] }
    let(:other_contributors) { [{ 'name' => 'Alan Turing' }] }

    it 'merges creators and contributors' do
      expect(contributors.pluck('name')).to contain_exactly('Ada Lovelace', 'Alan Turing')
    end

    it 'tags creators with the Creator role' do
      expect(contributors.find { |contributor| contributor['name'] == 'Ada Lovelace' }['role']).to eq('Creator')
    end

    context 'when a creator and a contributor share a name and identifiers' do
      let(:creators) { [{ 'name' => 'Sam Smith', 'name_identifiers' => [] }] }
      let(:other_contributors) { [{ 'name' => 'Sam Smith', 'name_identifiers' => [] }] }

      it 'de-duplicates them into a single entry' do
        expect(contributors.size).to eq(1)
      end
    end
  end

  describe '#affiliations_for' do
    subject(:document) { described_class.new(creators_struct_ss: creators.to_json) }

    let(:creators) do
      [{ 'name' => 'Ada Lovelace', 'affiliation' => [{ 'name' => 'Stanford University' }] }]
    end

    it 'returns the affiliations recorded for the named contributor' do
      expect(document.affiliations_for('Ada Lovelace')).to eq([{ 'name' => 'Stanford University' }])
    end

    it 'returns an empty list for a contributor not on the dataset' do
      expect(document.affiliations_for('Alan Turing')).to eq([])
    end
  end

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
