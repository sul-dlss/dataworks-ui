# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Feedback::FeedbackStandaloneComponent, type: :component do
  before do
    allow(vc_test_controller.request).to receive(:referer).and_return('http://localhost:3000')
    render_inline(described_class.new)
  end

  it 'renders a standalone container' do
    expect(page).to have_css('div.standalone')
  end

  it 'displays the form title' do
    expect(page).to have_css('h1', text: 'Send feedback')
  end

  it 'displays the reporting from bar' do
    expect(page).to have_text('Reporting from')
    expect(page).to have_text('http://localhost:3000')
  end

  it 'has a send button' do
    expect(page).to have_button('Send')
  end
end
