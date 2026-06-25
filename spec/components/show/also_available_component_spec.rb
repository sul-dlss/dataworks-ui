# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::AlsoAvailableComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:document) do
    SolrDocument.new(provider_identifier_map_struct_ss: providers.to_json, url_ss: landing_url)
  end
  let(:landing_url) { 'https://example.com/landing' }

  before { render_inline(component) }

  context 'with providers that map to external records' do
    let(:providers) { { 'Dryad' => '10.5061/dryad.abc', 'Zenodo' => '12345' } }

    it 'renders the section heading' do
      expect(page).to have_css('h2', text: 'Also available at')
    end

    it 'links each provider to its external record' do
      expect(page).to have_link('Dryad', href: 'https://datadryad.org/dataset/10.5061/dryad.abc')
      expect(page).to have_link('Zenodo', href: 'https://zenodo.org/records/12345')
    end

    it 'opens the links in a new tab' do
      expect(page).to have_css("a[href='https://datadryad.org/dataset/10.5061/dryad.abc'][target='_blank']")
    end
  end

  context 'when a provider URL is the same as the landing page URL' do
    let(:landing_url) { 'https://zenodo.org/records/12345' }
    let(:providers) { { 'Zenodo' => '12345', 'Dryad' => '10.5061/dryad.abc' } }

    it 'renders only the other provider' do
      expect(page).to have_css('a', count: 1)
      expect(page).to have_link('Dryad', href: 'https://datadryad.org/dataset/10.5061/dryad.abc')
    end
  end

  context 'when the landing page URL differs from a provider URL only by scheme' do
    let(:landing_url) { 'http://datadryad.org/dataset/10.5061/dryad.abc' }
    let(:providers) { { 'Dryad' => '10.5061/dryad.abc', 'Zenodo' => '12345' } }

    it 'still treats that provider as the landing page and omits it' do
      expect(page).to have_css('a', count: 1)
      expect(page).to have_link('Zenodo', href: 'https://zenodo.org/records/12345')
    end
  end

  context 'when a provider has no URL mapping' do
    let(:providers) { { 'Dryad' => '10.5061/dryad.abc', 'Figshare' => '999' } }

    it 'renders only the providers with a known URL' do
      expect(page).to have_css('a', count: 1)
      expect(page).to have_link('Dryad', href: 'https://datadryad.org/dataset/10.5061/dryad.abc')
    end
  end
end
