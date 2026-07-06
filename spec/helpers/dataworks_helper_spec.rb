# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataworksHelper do
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
