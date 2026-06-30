# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Landing page' do
  before { visit root_path }

  it 'renders the page title' do
    expect(page).to have_title('DataWorks')
  end

  it 'renders the search form inside the hero section' do
    expect(page).to have_css('.landing-hero form.search-query-form')
  end

  it 'renders the beta notice' do
    expect(page).to have_text('DataWorks is currently in beta')
  end

  it 'renders the Send feedback link' do
    expect(page).to have_link(I18n.t('landing_page.feedback_button'), href: feedback_path)
  end

  context 'when popular subjects are returned from Solr' do
    before do
      solr_response = {
        'facet_counts' => {
          'facet_fields' => {
            'subjects_ssim' => ['Climate Change', 120, 'Ocean Science', 85]
          }
        }
      }
      solr_client = instance_double(RSolr::Client, get: solr_response)
      allow(Rails.cache).to receive(:fetch).and_yield
      allow(RSolr).to receive(:connect).and_return(solr_client)
      visit root_path
    end

    it 'renders subject pills as links to facet searches' do
      expect(page).to have_link('Climate Change',
                                href: search_catalog_path(f: { subjects_ssim: ['Climate Change'] }))
      expect(page).to have_link('Ocean Science',
                                href: search_catalog_path(f: { subjects_ssim: ['Ocean Science'] }))
    end
  end
end
