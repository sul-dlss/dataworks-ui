# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Feedback::FeedbackFormFieldsComponent, type: :component do
  let(:form) { instance_double(ActionView::Helpers::FormBuilder) }

  before do
    allow(form).to receive_messages(
      hidden_field: ''.html_safe,
      label: ''.html_safe,
      text_field: '<input type="text" name="name">'.html_safe,
      email_field: '<input type="email" name="to" required="required">'.html_safe,
      text_area: '<textarea name="message" required="required"></textarea>'.html_safe
    )
    render_inline(described_class.new(form:, request_referer: 'http://localhost:3000'))
  end

  it 'renders a required email field' do
    expect(page).to have_css("input[name='to'][required='required']")
  end

  it 'renders a required message field' do
    expect(page).to have_css("textarea[name='message'][required='required']")
  end

  it 'renders a name field' do
    expect(page).to have_field(name: 'name')
  end
end
