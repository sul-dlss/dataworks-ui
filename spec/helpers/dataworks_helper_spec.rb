# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataworksHelper do
  let(:search_state) { Blacklight::SearchState.new(ActionController::Parameters.new, CatalogController.blacklight_config) }

  before do
    without_partial_double_verification do
      allow(helper).to receive(:search_state).and_return(search_state)
      allow(helper).to receive(:search_action_path) { |state| search_catalog_path(state.to_h) }
    end
  end

  describe '#add_facet_link' do
    it 'links to a catalog search with the facet applied' do
      link = helper.add_facet_link('funders_ssim', 'National Science Foundation')
      href = '/catalog?f%5Bfunders_ssim%5D%5B%5D=National+Science+Foundation&search_field=all_fields'
      expect(link).to have_link('National Science Foundation', href:)
    end

    context 'when the current request already has a search_field' do
      let(:search_state) do
        Blacklight::SearchState.new(ActionController::Parameters.new(search_field: 'title', q: 'water'),
                                    CatalogController.blacklight_config)
      end

      it 'preserves the existing search_field rather than overriding it' do
        link = helper.add_facet_link('funders_ssim', 'National Science Foundation')
        expect(link).to have_link('National Science Foundation', href: /search_field=title/)
      end
    end
  end

  describe '#display_funding_information' do
    it 'renders funder name as a catalog search link with award details' do
      value = [[{ funder_name: 'National Science Foundation', award_number: '12345' }].to_json]
      result = helper.display_funding_information(value:)
      href = '/catalog?f%5Bfunders_ssim%5D%5B%5D=National+Science+Foundation&search_field=all_fields'
      expect(result).to have_link('National Science Foundation', href:)
      expect(result).to include('Award number 12345')
    end
  end

  describe '#display_temporal_coverage' do
    it 'collapses a run of consecutive years into a single range' do
      expect(helper.display_temporal_coverage(value: [1990, 1991, 1992, 1995]))
        .to eq('1990–1992, 1995')
    end

    it 'leaves non-consecutive years as individual values' do
      expect(helper.display_temporal_coverage(value: [1918, 1939, 1961]))
        .to eq('1918, 1939, 1961')
    end

    it 'sorts and de-duplicates years before grouping' do
      expect(helper.display_temporal_coverage(value: [1992, 1990, 1991, 1990]))
        .to eq('1990–1992')
    end

    it 'accepts year values given as strings' do
      expect(helper.display_temporal_coverage(value: %w[2000 2001 2002]))
        .to eq('2000–2002')
    end

    it 'returns nil when there are no years' do
      expect(helper.display_temporal_coverage(value: [])).to be_nil
    end
  end
end
