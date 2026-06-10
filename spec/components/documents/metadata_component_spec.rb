# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Documents::MetadataComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:description) { nil }
  let(:url) { nil }
  let(:access) { nil }
  let(:document) do
    instance_double(SolrDocument, description:, url:, access:, stanford_authored?: false, subjects: [])
  end

  before { render_inline(component) }

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
