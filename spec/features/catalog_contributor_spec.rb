# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Catalog contributor' do
  let(:contributor) { 'Rasmussen, Anna' }

  context 'when requested directly (e.g. new tab)' do
    it 'renders with the full layout' do
      visit contributor_catalog_path(f: { contributors_ssim: [contributor] })
      expect(page).to have_css('form.search-query-form')
      expect(page).to have_text(contributor)
    end
  end
end
