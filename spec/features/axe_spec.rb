# frozen_string_literal: true

require 'rails_helper'
require 'axe-rspec'

RSpec.describe 'Accessibility testing', :js do
  let(:doc_id) { '10_5061_dryad_ngf1vhhrp' }

  it 'validates the landing page' do
    visit root_path
    expect(page).to be_accessible
  end

  it 'validates the search results page' do
    visit search_catalog_path(q: '', search_field: 'all_fields')
    expect(page).to be_accessible
  end

  it 'validates a search results page with an active facet' do
    visit search_catalog_path(q: '', search_field: 'all_fields', f: { stanford_contributor_bsi: [true] })
    expect(page).to be_accessible
  end

  it 'validates the record show page' do
    visit "/catalog/#{doc_id}"
    expect(page).to be_accessible
  end

  it 'validates the feedback page' do
    visit feedback_path
    expect(page).to be_accessible
  end

  def be_accessible
    be_axe_clean
  end
end
