# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Index::MetadataComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:description) { nil }
  let(:url) { nil }
  let(:access) { nil }
  let(:publication_year) { nil }
  let(:document) do
    instance_double(SolrDocument, description:, url:, access:, publication_year:, stanford_authored?: false,
                                  subjects: [])
  end

  before { render_inline(component) }

  context 'when a publication year is present' do
    let(:publication_year) { 1998 }

    it 'renders the publication year' do
      expect(page).to have_css('p.document-publication-year', text: 'Published: 1998')
    end
  end

  context 'when a description is present' do
    let(:description) { 'A dataset about something interesting.' }

    it 'renders the description preview' do
      expect(page).to have_css('div.document-description', text: 'A dataset about something interesting.')
    end
  end

  context 'when a url is present' do
    let(:url) { 'https://example.com/dataset' }
    let(:access) { 'public' }

    it 'renders the access button' do
      expect(page).to have_link(href: url)
    end
  end
end
