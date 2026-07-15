# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Badges::AccessComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:document) { instance_double(SolrDocument, access:) }

  context 'when access is restricted' do
    let(:access) { 'restricted' }

    before { render_inline(component) }

    it 'renders the restricted badge as a facet link' do
      expect(page).to have_css('a.badge.access-badge.restricted', text: 'Restricted')
    end

    it 'links to add the restricted access filter' do
      badge = page.find('a.access-badge')
      expect(badge['href']).to include('f%5Baccess_ssi%5D%5B%5D=restricted')
      expect(badge['aria-pressed']).to eq('false')
    end

    it 'renders the lock icon' do
      expect(page).to have_css('.blacklight-icons-lock_closed')
    end
  end

  context 'when access is public' do
    let(:access) { 'public' }

    before { render_inline(component) }

    it 'renders the public badge as a facet link' do
      expect(page).to have_css('a.badge.access-badge.public', text: 'Public')
    end

    it 'links to add the public access filter' do
      badge = page.find('a.access-badge')
      expect(badge['href']).to include('f%5Baccess_ssi%5D%5B%5D=public')
    end

    it 'renders the lock open icon' do
      expect(page).to have_css('.blacklight-icons-lock_open')
    end
  end

  context 'when the access value is already an active filter' do
    let(:access) { 'public' }

    before do
      with_request_url '/catalog?f%5Baccess_ssi%5D%5B%5D=public' do
        render_inline(component)
      end
    end

    it 'marks the badge as pressed and links to remove the filter' do
      badge = page.find('a.access-badge')
      expect(badge['class']).to include('access-badge--selected')
      expect(badge['aria-pressed']).to eq('true')
      expect(badge['href']).not_to include('access_ssi')
    end

    it 'retains a search_field so removing the only filter stays on the results page' do
      expect(page.find('a.access-badge')['href']).to include('search_field=all_fields')
    end

    it 'replaces the lock icon with the check icon' do
      expect(page).to have_css('svg.bi-check')
    end
  end

  context 'when access is blank' do
    let(:access) { nil }

    before { render_inline(component) }

    it 'renders nothing' do
      expect(page).to have_no_css('.badge')
    end
  end
end
