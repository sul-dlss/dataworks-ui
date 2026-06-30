# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LandingPage::HeaderComponent, type: :component do
  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.add_search_field('all_fields', label: 'All Fields')
      config.index.search_bar_component = Index::SearchBarComponent
    end
  end

  let(:component) { described_class.new(blacklight_config: blacklight_config) }

  before do
    allow(vc_test_controller).to receive_messages(
      blacklight_config: blacklight_config,
      search_action_url: '/catalog',
      params: ActionController::Parameters.new
    )
  end

  it 'hides the search bar' do
    expect(component.show_search_bar?).to be false
  end

  it 'removes the header bottom margin' do
    expect(component.header_css_class).to eq('')
  end

  it 'renders the identity bar' do
    render_inline(component)
    expect(page).to have_link('Stanford University', href: 'https://www.stanford.edu')
  end
end
