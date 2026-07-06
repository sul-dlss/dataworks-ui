# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::SubjectsComponent, type: :component do
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
    let(:subjects) { ['Biology', 'Climate change'] }

    before { render_inline(component) }

    it 'renders a pill for each subject' do
      expect(page).to have_css('.document-subjects .document-subjects__pill', count: 2)
    end

    it 'links each pill to its facet search' do
      expect(page).to have_link('Biology', href: %r{/catalog\?f%5Bsubjects_ssim%5D%5B%5D=Biology})
      expect(page).to have_link('Climate change',
                                href: %r{/catalog\?f%5Bsubjects_ssim%5D%5B%5D=Climate\+change})
    end

    it 'marks each subject as an expand-items item' do
      expect(page).to have_css("ul.document-subjects[data-controller='expand-items']")
      expect(page).to have_css("li[data-expand-items-target='item']", count: 2)
    end
  end
end
