# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Badges::SubjectPillComponent, type: :component do
  subject(:component) { described_class.new(subject: 'Biology', path: '/catalog?q=Biology', **options) }

  let(:options) { {} }

  context 'when rendered as a plain navigational pill' do
    before { render_inline(component) }

    it 'renders a pill linking to the given path' do
      expect(page).to have_link('Biology', href: '/catalog?q=Biology')
      expect(page).to have_css('a.badge.rounded-pill.document-subjects__pill', text: 'Biology')
    end

    it 'omits the toggle affordances' do
      link = page.find('.document-subjects__pill')
      expect(link['aria-current']).to be_nil
      expect(link).to have_no_css('.document-subjects__pill--selected')
    end
  end

  context 'when rendered as an unselected toggle' do
    let(:options) { { selected: false } }

    before { render_inline(component) }

    it 'does not mark the pill as current' do
      expect(page.find('.document-subjects__pill')['aria-current']).to be_nil
    end
  end

  context 'when rendered as a selected toggle' do
    let(:options) { { selected: true } }

    before { render_inline(component) }

    it 'marks the pill as current with the selected modifier and a check icon' do
      selected = page.find('.document-subjects__pill--selected')
      expect(selected['aria-current']).to eq('true')
      expect(selected).to have_text('Biology')
      expect(selected).to have_css('svg.bi-check')
    end
  end
end
