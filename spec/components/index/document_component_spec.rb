# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Index::DocumentComponent, type: :component do
  subject(:component) { described_class.new(document:, counter: 1) }

  let(:view_context) { vc_test_controller.view_context }
  let(:blacklight_config) do
    CatalogController.blacklight_config.deep_copy.tap do |config|
      config.track_search_session.storage = false
    end
  end
  let(:presented_document) do
    SolrDocument.new(
      id: 'abc-123',
      title_tsim: 'My Dataset',
      access_ssi: 'restricted',
      descriptions_tsim: 'A description of the dataset.',
      url_ss: 'https://example.com/dataset'
    )
  end
  let(:document) { view_context.document_presenter(presented_document) }

  before do
    allow(vc_test_controller).to receive_messages(
      view_context: view_context,
      current_or_guest_user: nil,
      blacklight_config: blacklight_config
    )
    without_partial_double_verification do
      allow(view_context).to receive_messages(search_session: {}, current_search_session: nil, current_bookmarks: [])
    end
    vc_test_controller.action_name = 'index'
    render_inline(component)
  end

  it 'renders the document title' do
    expect(page).to have_link 'My Dataset', href: '/catalog/abc-123'
  end

  it 'renders the document counter' do
    expect(page).to have_css 'header', text: '1. My Dataset'
  end

  it 'renders the metadata component' do
    expect(page).to have_css '.document-metadata'
  end

  it 'renders the description' do
    expect(page).to have_css 'div.document-description', text: 'A description of the dataset.'
  end

  it 'renders the access data button' do
    expect(page).to have_link 'Access data', href: 'https://example.com/dataset'
  end
end
