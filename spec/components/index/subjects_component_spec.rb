# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Index::SubjectsComponent, type: :component do
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

    it 'links each pill to its facet search' do
      expect(page).to have_link('Biology', href: %r{/catalog\?f%5Bsubjects_ssim%5D%5B%5D=Biology})
      expect(page).to have_link('Climate change',
                                href: %r{/catalog\?f%5Bsubjects_ssim%5D%5B%5D=Climate\+change})
    end
  end

  context 'when a subject is already an active filter' do
    let(:subjects) { ['Biology', 'Climate change'] }

    before do
      with_request_url '/catalog?f%5Bsubjects_ssim%5D%5B%5D=Biology' do
        render_inline(component)
      end
    end

    it 'marks the selected pill as pressed and links it to remove the filter' do
      selected = page.find('.document-subjects__pill--selected')
      expect(selected).to have_text('Biology')
      expect(selected['aria-pressed']).to eq('true')
      expect(selected['href']).not_to include('subjects_ssim')
      expect(selected).to have_css('svg.bi-check')
    end

    it 'keeps the deselect link on the results page when it clears the last filter' do
      selected = page.find('.document-subjects__pill--selected')
      expect(selected['href']).to include('search_field=all_fields')
    end

    it 'still links an unselected pill to add its filter' do
      climate = page.find('.document-subjects__pill', text: 'Climate change')
      expect(climate['href']).to include('f%5Bsubjects_ssim%5D%5B%5D=Climate+change')
      expect(climate['aria-pressed']).to eq('false')
    end
  end
end
