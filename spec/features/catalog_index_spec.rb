# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Catalog index' do
  it 'renders the search page with seeded data in facets' do
    visit '/'
    expect(page).to have_title('DataWorks Experimental Prototype')
    expect(page).to have_css('form.search-query-form')
    expect(page).to have_text('figshare')
    expect(page).to have_text('Public')
  end
end
