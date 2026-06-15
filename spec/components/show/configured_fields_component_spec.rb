# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::ConfiguredFieldsComponent, type: :component do
  subject(:component) { described_class.new(presenter:) }

  let(:view_context) { vc_test_controller.view_context }
  let(:blacklight_config) do
    CatalogController.blacklight_config.deep_copy.tap do |config|
      config.track_search_session.storage = false
    end
  end
  let(:presented_document) do
    SolrDocument.new(id: 'abc-123', doi_ssi: '10.0000/example')
  end
  let(:presenter) { view_context.document_presenter(presented_document) }

  before do
    allow(vc_test_controller).to receive_messages(
      view_context: view_context,
      blacklight_config: blacklight_config
    )
    vc_test_controller.action_name = 'show'
    render_inline(component)
  end

  it 'renders configured show_fields using Blacklight metadata rendering' do
    expect(page).to have_text 'DOI'
    expect(page).to have_text '10.0000/example'
  end
end
