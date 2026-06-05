# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Catalog show' do
  let(:doc_id) { '10_5061_dryad_ngf1vhhrp' }
  let(:fixture_title) do
    'Association of CSF biomarkers with hippocampal-dependent memory in preclinical Alzheimer disease V1'
  end

  it 'renders the record page with key metadata' do
    visit "/catalog/#{doc_id}"
    expect(page).to have_title(fixture_title)
    expect(page).to have_text(fixture_title)
    expect(page).to have_text('10.5061/dryad.ngf1vhhrp')
    expect(page).to have_text('2021')
  end
end
