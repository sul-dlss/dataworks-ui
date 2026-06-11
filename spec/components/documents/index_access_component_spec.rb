# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Documents::IndexAccessComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:url) { 'https://example.com/dataset' }
  let(:document) { instance_double(SolrDocument, url:) }

  before { render_inline(component) }

  it 'renders the available at label with the url host' do
    expect(page).to have_text('Available at example.com')
  end

  it 'renders a bordered container' do
    expect(page).to have_css('div.border.rounded-2')
  end

  it 'renders a link to the document url' do
    expect(page).to have_link(href: url)
  end

  it 'renders the access button label' do
    expect(page).to have_link(text: /Access data/)
  end

  it 'opens in a new tab' do
    expect(page).to have_css('a[target="_blank"]')
  end

  it 'includes rel noopener' do
    expect(page).to have_css('a[rel="noopener"]')
  end
end
