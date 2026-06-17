# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::SubjectsComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:subjects) { ['Biology', 'Climate change'] }
  let(:document) { instance_double(SolrDocument, subjects:) }

  before { render_inline(component) }

  it 'links each subject to its facet search' do
    expect(page).to have_link('Biology', href: %r{/catalog\?f%5Bsubjects_ssim%5D%5B%5D=Biology})
    expect(page).to have_link('Climate change',
                              href: %r{/catalog\?f%5Bsubjects_ssim%5D%5B%5D=Climate\+change})
  end

  it 'sets the expand-items controller to show a fixed number of rows' do
    expect(page).to have_css(
      "div[data-controller='expand-items'][data-expand-items-max-rows-value='#{described_class::VISIBLE_COUNT}']"
    )
  end

  it 'marks each subject as an expand-items item' do
    expect(page).to have_css("li[data-expand-items-target='item']", count: 2)
  end

  it 'renders a toggle with show more/less controls, hidden until JS reveals it' do
    expect(page).to have_css(
      "button[data-expand-items-target='toggle'][data-action='expand-items#toggle'][hidden]", visible: :all
    )
    expect(page).to have_css("[data-expand-items-target='moreControl']", text: 'Show more', visible: :all)
    expect(page).to have_css("[data-expand-items-target='lessControl']", text: 'Show less', visible: :all)
  end
end
