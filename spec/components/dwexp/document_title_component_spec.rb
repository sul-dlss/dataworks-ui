# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dwexp::DocumentTitleComponent, type: :component do
  let(:view_context) { vc_test_controller.view_context }
  let(:blacklight_config) do
    CatalogController.blacklight_config.deep_copy.tap do |config|
      config.track_search_session.storage = false
    end
  end
  let(:presented_document) do
    SolrDocument.new(id: 'abc-123', access_ssi: 'public', stanford_contributor_bsi: true)
  end
  let(:presenter) { Blacklight::ShowPresenter.new(presented_document, view_context) }

  before do
    allow(vc_test_controller).to receive_messages(
      view_context: view_context,
      blacklight_config: blacklight_config
    )
  end

  # link_to_document/actions are disabled to isolate the badge logic from the
  # link and document-action helpers, which aren't relevant here.
  def render_title(**)
    render_inline(described_class.new('My Dataset', presenter:, link_to_document: false, actions: false, **))
  end

  it 'renders the access badge by default' do
    render_title
    expect(page).to have_css('span.badge.access-badge.public', text: 'Public')
  end

  context 'when access_badge: false' do
    it 'does not render the access badge (the caller renders it elsewhere)' do
      render_title(access_badge: false)
      expect(page).to have_no_css('span.badge.access-badge')
    end

    it 'still renders the Stanford authored badge' do
      render_title(access_badge: false)
      expect(page).to have_css('span.badge.stanford-authored', text: 'Stanford Authored')
    end

    context 'when the dataset is also not Stanford authored' do
      let(:presented_document) do
        SolrDocument.new(id: 'abc-123', access_ssi: 'public', stanford_contributor_bsi: false)
      end

      it 'omits the badge wrapper entirely rather than leaving an empty, spaced-out div' do
        render_title(access_badge: false)
        expect(page).to have_no_css('span.badge')
        expect(page).to have_no_css('div.align-items-center.mb-2')
      end
    end
  end
end
