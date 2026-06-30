# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Index::SearchBarComponent, type: :component do
  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_search_field('all_fields', label: 'All Fields')
      config.add_search_field('title', label: 'Title')
      config.autocomplete_enabled = true
      config.advanced_search.enabled = false
    end
  end

  let(:component) do
    described_class.new(
      url: '/catalog',
      params: { q: '' },
      autocomplete_path: '/catalog/suggest'
    )
  end

  before do
    allow(vc_test_controller).to receive(:blacklight_config).and_return(blacklight_config)
    render_inline(component)
  end

  it 'renders with the correct form classes' do
    expect(page).to have_css('form.search-query-form')
  end

  it 'renders the search button' do
    expect(page).to have_button(nil, type: 'submit', class: 'search-btn')
  end

  it 'applies default search container classes' do
    expect(page).to have_css('search.search-card')
  end

  context 'when custom search_classes are passed' do
    let(:component) do
      described_class.new(
        url: '/catalog',
        params: { q: '' },
        autocomplete_path: '/catalog/suggest',
        search_classes: %w[search-card rounded]
      )
    end

    it 'applies the custom classes to the search container' do
      expect(page).to have_css('search.search-card.rounded')
    end
  end
end
