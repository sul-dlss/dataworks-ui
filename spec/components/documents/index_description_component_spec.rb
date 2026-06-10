# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Documents::IndexDescriptionComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:description) { nil }
  let(:document) { instance_double(SolrDocument, description:) }

  context 'when description is blank' do
    it 'renders nothing' do
      render_inline(component)
      expect(page).to have_no_css('.document-description')
    end
  end

  context 'when a description is present' do
    let(:description) { 'A dataset about something interesting.' }

    before { render_inline(component) }

    it 'renders the description with expand/collapse controls' do
      expect(page).to have_css('div.document-description[data-controller="expand-text"]')
      expect(page).to have_css('[data-expand-text-target="content"]')
      expect(page).to have_css('[data-expand-text-target="toggle"]')
    end
  end
end
