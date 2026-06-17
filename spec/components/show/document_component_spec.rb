# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::DocumentComponent, type: :component do
  subject(:component) { described_class.new(document:, show: true) }

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
      variables_tsim: ['Variable 1']
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
    vc_test_controller.action_name = 'show'
    render_inline(component)
  end

  it 'renders the document title' do
    expect(page).to have_text 'My Dataset'
  end

  it 'renders the metadata wrapper' do
    expect(page).to have_css '.document-metadata'
  end

  it 'renders the configured show_fields through the bridge' do
    expect(page).to have_text 'Variables'
    expect(page).to have_text 'Variable 1'
  end
end
