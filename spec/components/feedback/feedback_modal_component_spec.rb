# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Feedback::FeedbackModalComponent, type: :component do
  before do
    allow(vc_test_controller.request).to receive(:referer).and_return('http://localhost:3000')
    render_inline(described_class.new)
  end

  it 'has a link to open in a new tab' do
    expect(page).to have_link('Open in new tab', href: '/feedback/new')
  end

  it 'displays the reporting from bar' do
    expect(page).to have_text('Reporting from')
    expect(page).to have_text('http://localhost:3000')
  end

  it 'has a send button' do
    expect(page).to have_button('Send')
  end

  it 'has a close button' do
    expect(page).to have_button('Close')
  end
end
