# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::ContentSummaryComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:document) { instance_double(SolrDocument, description_html:) }

  context 'when a description is present' do
    let(:description_html) { 'H<sub>2</sub>O sampling <em>notes</em>.' }

    before { render_inline(component) }

    it 'renders the content summary section' do
      expect(page).to have_css('#content-summary')
    end

    it 'renders the description as rich text, preserving inline markup' do
      expect(page).to have_css('.rich-text sub', text: '2')
      expect(page).to have_css('.rich-text em', text: 'notes')
    end
  end
end
