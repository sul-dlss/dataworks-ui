# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::RightsComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:document) { SolrDocument.new(rights_list_struct_ss: rights_list.to_json) }

  before { render_inline(component) }

  context 'when an item has both an identifier and a URI' do
    let(:rights_list) do
      [{ 'rights' => 'Creative Commons Attribution 4.0',
         'rights_identifier' => 'CC-BY-4.0',
         'rights_uri' => 'https://creativecommons.org/licenses/by/4.0/' }]
    end

    it 'renders the heading and subheading' do
      expect(page).to have_css('h2', text: 'Rights')
      expect(page).to have_css('h3', text: 'License')
    end

    it 'links the identifier to the URI, opening in a new tab' do
      expect(page).to have_css(
        "a[href='https://creativecommons.org/licenses/by/4.0/'][target='_blank']",
        text: 'CC-BY-4.0'
      )
    end
  end

  context 'when an item has only rights text' do
    let(:rights_list) { [{ 'rights' => 'All rights reserved' }] }

    it 'renders the text' do
      expect(page).to have_text('All rights reserved')
    end
  end

  context 'when an item has only a URI' do
    let(:rights_list) { [{ 'rights_uri' => 'https://example.com/license' }] }

    it 'links the URI to itself, opening in a new tab' do
      expect(page).to have_css(
        "a[href='https://example.com/license'][target='_blank']",
        text: 'https://example.com/license'
      )
    end
  end

  context 'when an item has an identifier but no URI' do
    let(:rights_list) { [{ 'rights_identifier' => 'CC0-1.0' }] }

    it 'renders the identifier as text' do
      expect(page).to have_text('CC0-1.0')
    end
  end

  context 'with multiple items' do
    let(:rights_list) do
      [{ 'rights_identifier' => 'CC-BY-4.0', 'rights_uri' => 'https://creativecommons.org/licenses/by/4.0/' },
       { 'rights' => 'All rights reserved' }]
    end

    it 'renders each item' do
      expect(page).to have_link('CC-BY-4.0', href: 'https://creativecommons.org/licenses/by/4.0/')
      expect(page).to have_text('All rights reserved')
    end
  end
end
