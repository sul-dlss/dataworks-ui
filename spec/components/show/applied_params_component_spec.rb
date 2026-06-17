# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::AppliedParamsComponent, type: :component do
  let(:component) { described_class.new }

  before do
    # Stub the Blacklight helpers the component delegates to, so it renders
    # outside a full search session.
    allow(component).to receive(:current_search_session).and_return(true)
    allow(component).to receive(:link_back_to_catalog) do |opts|
      ActionController::Base.helpers.link_to(opts[:label], '/catalog', class: opts[:class])
    end
    render_inline(component)
  end

  it 'renders a "Search results" back-to-catalog link styled as a link, not a button' do
    expect(page).to have_link('Search results', href: '/catalog')
    expect(page).to have_css('a.back-to-search-link', text: 'Search results')
  end

  it 'renders the backward-pointing icon inside the link' do
    expect(page).to have_css('a.back-to-search-link svg.bi-backward-fill')
  end
end
