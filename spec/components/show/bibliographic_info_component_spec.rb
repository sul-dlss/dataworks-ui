# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::BibliographicInfoComponent, type: :component do
  subject(:component) { described_class.new(presenter:) }

  let(:view_context) { vc_test_controller.view_context }
  let(:blacklight_config) do
    CatalogController.blacklight_config.deep_copy.tap do |config|
      config.track_search_session.storage = false
    end
  end
  let(:presented_document) do
    SolrDocument.new(id: 'abc-123', geo_place_ssim: ['Antarctica'])
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

  it 'renders the section heading' do
    expect(page).to have_css 'h2', text: 'Bibliographic information'
  end

  it 'renders configured show_fields using Blacklight metadata rendering' do
    expect(page).to have_text 'Geographic coverage'
    expect(page).to have_text 'Antarctica'
  end

  it 'renders field labels without a trailing colon' do
    expect(page).to have_css 'dt', exact_text: 'Geographic coverage', normalize_ws: true
  end

  context 'when none of the configured fields have a value' do
    let(:presented_document) { SolrDocument.new(id: 'abc-123') }

    it 'renders nothing, including the heading' do
      expect(page).to have_no_css 'h2'
      expect(page).to have_no_text 'Bibliographic information'
    end
  end
end
