# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Badges::AccessComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:document) { instance_double(SolrDocument, access:) }

  before { render_inline(component) }

  context 'when access is restricted' do
    let(:access) { 'restricted' }

    it 'renders the restricted badge' do
      expect(page).to have_css('span.badge.restricted', text: 'Restricted')
    end

    it 'renders the lock icon' do
      expect(page).to have_css('.blacklight-icons-lock_closed')
    end
  end

  context 'when access is public' do
    let(:access) { 'public' }

    it 'renders the public badge' do
      expect(page).to have_css('span.badge.public', text: 'Public')
    end

    it 'renders the lock open icon' do
      expect(page).to have_css('.blacklight-icons-lock_open')
    end
  end

  context 'when access is blank' do
    let(:access) { nil }

    it 'renders nothing' do
      expect(page).to have_no_css('span.badge')
    end
  end
end
