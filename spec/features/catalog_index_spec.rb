# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Catalog index' do
  it 'renders the search page with seeded data in facets' do
    visit search_catalog_path(q: '', search_field: 'all_fields')
    expect(page).to have_title('DataWorks')
    expect(page).to have_css('form.search-query-form')
    expect(page).to have_text('figshare')
    expect(page).to have_text('Public')
  end

  context 'when on the search results page' do
    before { visit search_catalog_path(q: '', search_field: 'all_fields') }

    it 'renders the mobile Filters button linked to the offcanvas' do
      expect(page).to have_css('button[data-bs-toggle="offcanvas"][data-bs-target="#offcanvas-facets"]',
                               text: 'Filters')
    end

    it 'renders the offcanvas facets panel with the Filters heading' do
      expect(page).to have_css('#offcanvas-facets')
      expect(page).to have_css('#offcanvas-facets h2', text: I18n.t('blacklight.search.facets.title'))
    end

    it 'renders the Stanford-authored facet inside the offcanvas, not in the main sidebar' do
      expect(page).to have_css('#offcanvas-facets a.btn-stanford-cardinal')
      expect(page).to have_no_css('#sidebar .btn-stanford-cardinal')
    end

    context 'when the Stanford dataset facet is active' do
      before { visit search_catalog_path(q: '', search_field: 'all_fields', f: { stanford_contributor_bsi: [true] }) }

      it 'marks the Stanford dataset facet button as active' do
        expect(page).to have_css('#offcanvas-facets a.btn-stanford-cardinal.active')
      end
    end
  end
end
