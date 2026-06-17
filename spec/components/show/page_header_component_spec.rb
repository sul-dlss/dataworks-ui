# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::PageHeaderComponent, type: :component do
  # Render with the real Blacklight sub-components replaced by stub components,
  # so this spec exercises only the layout this override is responsible for: the
  # back link and paging controls sharing one inline, wrapping, responsively
  # centered flex row. (The sub-components are covered by their own specs.)
  let(:component) do
    described_class.new(document: SolrDocument.new(id: 'x'), search_context: { next: SolrDocument.new(id: 'y') },
                        search_session: {})
  end

  let(:stub_component) do
    stub_const('StubComponent', Class.new(ViewComponent::Base) do
      def initialize(marker:)
        @marker = marker
        super()
      end

      def call
        content_tag(:span, @marker, class: @marker)
      end
    end)
  end

  before do
    allow(component).to receive_messages(
      applied_params_component: stub_component.new(marker: 'back-link'),
      pagination_component: stub_component.new(marker: 'paging-controls'),
      render_header_tools: nil,
      header_container_classes: 'pagination-search-widgets pb-3 mb-3'
    )
    render_inline(component)
  end

  it 'places the back link and paging controls together in one inline flex row' do
    row = page.find('.pagination-search-widgets .d-flex.flex-wrap.align-items-center')
    expect(row).to have_css('span.back-link')
    expect(row).to have_css('span.paging-controls')
  end

  it 'centers the row at medium and smaller widths, left-aligning from large up' do
    expect(page).to have_css('.d-flex.justify-content-center.justify-content-lg-start')
  end
end
