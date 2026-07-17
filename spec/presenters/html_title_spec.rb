# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HtmlTitle do
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:controller) do
    CatalogController.new.tap do |c|
      c.request = ActionDispatch::TestRequest.create
      c.response = ActionDispatch::Response.new
    end
  end
  let(:view_context) { controller.view_context }

  shared_examples 'an HTML-aware heading' do
    subject(:presenter) { described_class.new(document, view_context, blacklight_config) }

    let(:document) do
      SolrDocument.new(id: 'abc-123', title_html_tsm: ['<em>Deep</em> <span>sea</span> vents'])
    end

    context 'when the request format is HTML' do
      before { controller.request.format = :html }

      it 'keeps allowlisted markup and strips the rest, marking the result html_safe' do
        expect(presenter.heading).to eq('<em>Deep</em> sea vents')
        expect(presenter.heading).to be_html_safe
      end
    end

    context 'when the request format is JSON' do
      before { controller.request.format = :json }

      it 'returns plain text with the markup stripped' do
        expect(presenter.heading).to eq('Deep sea vents')
      end
    end

    context 'when the document has no HTML title' do
      let(:document) { SolrDocument.new(id: 'no-html-title', title_tsim: ['A plain title']) }

      before { controller.request.format = :html }

      it 'falls back to the document id' do
        expect(presenter.heading).to eq('no-html-title')
      end
    end
  end

  describe Index::DocumentPresenter do
    it_behaves_like 'an HTML-aware heading'
  end

  describe Show::DocumentPresenter do
    it_behaves_like 'an HTML-aware heading'
  end
end
