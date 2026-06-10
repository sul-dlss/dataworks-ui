# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blacklight::StartOverButtonComponent, type: :component do
  let(:blacklight_config) { Blacklight::Configuration.new }

  before do
    allow(vc_test_controller).to receive(:blacklight_config).and_return(blacklight_config)
    render_inline(described_class.new)
  end

  it 'renders with btn-outline-primary class' do
    expect(page).to have_css('a.btn.btn-outline-primary')
  end

  it 'renders "Clear all" as the link text' do
    expect(page).to have_link('Clear all')
  end
end
