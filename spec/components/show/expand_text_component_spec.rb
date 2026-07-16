# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::ExpandTextComponent, type: :component do
  it 'wraps block content in the expand-text controller markup' do
    render_inline(described_class.new) { 'Some long field value'.html_safe }

    expect(page).to have_css 'div[data-controller="expand-text"]'
    expect(page).to have_css '[data-expand-text-target="content"].expand-text--collapsed',
                             text: 'Some long field value'
  end

  it 'renders Show more/Show less toggle controls' do
    render_inline(described_class.new) { 'value'.html_safe }

    expect(page).to have_css 'button[data-action="expand-text#toggle"]'
    expect(page).to have_css '[data-expand-text-target="moreControl"]', text: 'Show more'
    # The less control starts hidden (collapsed state); the Stimulus controller reveals it.
    expect(page).to have_css '[data-expand-text-target="lessControl"][hidden]', text: 'Show less', visible: :all
  end

  it 'sets the line clamp from the lines argument' do
    render_inline(described_class.new(lines: 8)) { 'value'.html_safe }

    expect(page).to have_css '[style*="--expand-text-lines: 8"]'
  end
end
