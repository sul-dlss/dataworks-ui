# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Badges::StanfordAuthoredComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:document) { instance_double(SolrDocument, stanford_authored?: stanford_authored?) }

  context 'when the document is stanford authored' do
    let(:stanford_authored?) { true }

    before { render_inline(component) }

    it 'renders the stanford authored badge as a facet link' do
      expect(page).to have_link('Stanford Authored', class: 'badge stanford-authored')
    end

    it 'links to add the stanford-authored facet' do
      badge = page.find('a.stanford-authored')
      expect(badge['href']).to include('f%5Bstanford_contributor_bsi%5D%5B%5D=true')
      expect(badge['aria-pressed']).to eq('false')
    end
  end

  context 'when the stanford-authored facet is already an active filter' do
    let(:stanford_authored?) { true }

    before do
      with_request_url '/catalog?f%5Bstanford_contributor_bsi%5D%5B%5D=true' do
        render_inline(component)
      end
    end

    it 'marks the badge as pressed and links to remove the filter' do
      badge = page.find('a.stanford-authored')
      expect(badge['class']).to include('stanford-authored--selected')
      expect(badge['aria-pressed']).to eq('true')
      expect(badge['href']).not_to include('stanford_contributor_bsi')
      expect(badge).to have_css('svg.bi-check')
    end

    it 'retains a search_field so removing the only filter stays on the results page' do
      expect(page.find('a.stanford-authored')['href']).to include('search_field=all_fields')
    end
  end

  context 'when the document is not stanford authored' do
    let(:stanford_authored?) { false }

    before { render_inline(component) }

    it 'renders nothing' do
      expect(page).to have_no_css('.badge')
    end
  end
end
