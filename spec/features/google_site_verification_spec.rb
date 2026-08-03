# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Google site verification' do
  it 'includes the verification meta tag' do
    visit '/'
    expect(page).to have_css(
      'meta[name="google-site-verification"][content="abyPMNSENI9-BVzLcKBsxfpsl_lOq-3hN588Ip12ZTk"]',
      visible: :hidden
    )
  end
end
