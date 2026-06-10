# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Documents::IndexSubjectsComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:subjects) { [] }
  let(:document) { instance_double(SolrDocument, subjects:) }

  context 'when subjects are absent' do
    it 'renders nothing' do
      render_inline(component)
      expect(page).to have_no_css('.document-subjects')
    end
  end

  context 'when subjects are present' do
    let(:subjects) { ['Biology', 'Climate change', 'Ocean science'] }

    before { render_inline(component) }

    it 'renders a pill for each subject' do
      expect(page).to have_css('.document-subjects .document-subjects__pill', count: 3)
    end

    it 'displays the subject text' do
      expect(page).to have_css('.document-subjects__pill', text: 'Biology')
      expect(page).to have_css('.document-subjects__pill', text: 'Climate change')
      expect(page).to have_css('.document-subjects__pill', text: 'Ocean science')
    end
  end
end
