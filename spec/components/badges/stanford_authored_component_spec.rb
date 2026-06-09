# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Badges::StanfordAuthoredComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:document) { instance_double(SolrDocument, stanford_authored?: stanford_authored?) }

  before { render_inline(component) }

  context 'when the document is stanford authored' do
    let(:stanford_authored?) { true }

    it 'renders the stanford authored badge' do
      expect(page).to have_css('span.badge.stanford-authored', text: 'Stanford Authored')
    end
  end

  context 'when the document is not stanford authored' do
    let(:stanford_authored?) { false }

    it 'renders nothing' do
      expect(page).to have_no_css('span.badge')
    end
  end
end
